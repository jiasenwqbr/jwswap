// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract JW is IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    
    // === Events ===
    event GlobalBuyWhitelistUpdated(address indexed account, bool status);
    event TradeWhitelistUpdated(address indexed account, bool status);
    event TradeWhitelistBuyLimitUpdated(address indexed account, uint256 limit);
    event BuyFeeReceiverAdded(address indexed receiver, uint256 rate);
    event BuyFeeReceiverAddedNormal(address indexed receiver, uint256 rate);
    event SellFeeReceiverAdded(address indexed receiver, uint256 rate);
    event SellFeeReceiverAddedNormal(address indexed receiver, uint256 rate);
    event BuyFeeReceiverUpdated(uint256 indexed index, address receiver, uint256 rate);
    event SellFeeReceiverUpdated(uint256 indexed index, address receiver, uint256 rate);
    event BuyFeeReceiverUpdatedNormal(uint256 indexed index, address receiver, uint256 rate);
    event SellFeeReceiverUpdatedNormal(uint256 indexed index, address receiver, uint256 rate);
    event BuyFeeReceiverRemoved(uint256 indexed index);
    event SellFeeReceiverRemoved(uint256 indexed index);
    event BuyFeeReceiverRemovedNormal(uint256 indexed index);
    event SellFeeReceiverRemovedNormal(uint256 indexed index);
    event TradingEnabledUpdated(bool enabled);
    event PairEnabledStatusUpdated(address indexed pair, bool enabled);
    event ProfitDistribute(address from,address to,uint256 amount,uint256 timestamp);
    
    
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address => bool) public pairs;

    mapping(address => bool) public globalSellWhitelist;

    // 支持多个手续费接收者的结构体
    struct FeeReceiver {
        address receiver;
        uint256 rate; // 费率，基数10000，例如25表示2.5%
    }
    
    
    // 支持多个手续费接收者
    FeeReceiver[] public buyFeeReceivers;
    FeeReceiver[] public sellFeeReceivers;

    FeeReceiver[] public buyFeeReceiversNormal;
    FeeReceiver[] public sellFeeReceiversNormal;

    FeeReceiver[] public tradeProfitNormal;

    bool public tradeToPublic;

    address public operator;

    // 新增状态变量
    mapping(address => bool) public globalBuyWhitelist; 
   
    bool private sellTradingEnabled = true; // 交易开关
    bool private buyTradingEnabled = true; // 交易开关
    bool private transTradingEnabled = true; // 交易开关
    mapping(address => bool) public pairsEnabled; //交易对开放状态
    address private manageContract;
    address public swapRouterAddress;
    address public swapOrangeRouterAddress;

    bool public sellLimitAddressSwitch;
    bool public buyLimitAddressSwitch;
    mapping(address => bool) public sellLimitAddressWhitelist;
    mapping(address => bool) public buyLimitAddressWhitelist;
    
    address wethAddress;
    struct UserSwapNormal {
        uint256 totalHoldings;
        uint256 totalCost;
    }
    
    mapping(address => UserSwapNormal) userSwapNormals;
    address usdtAddress;


    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 mintAmount,
        address _receiver,
        IUniswapV2Router02 _iUniswapV2Router02,
        address _swapOrangeRouterAddress,
        address _operator,
        address _wethAddress,
        address _manageContract,
        address _usdtAddress
        
    ) {
        // 初始化后通过 addBuyFeeReceiver/addSellFeeReceiver 设置手续费接收者
        IUniswapV2Factory iUniswapV2Factory = IUniswapV2Factory(
            _iUniswapV2Router02.factory()
        );
        swapRouterAddress = address(_iUniswapV2Router02);
        swapOrangeRouterAddress = _swapOrangeRouterAddress;
        address pair2 = iUniswapV2Factory.createPair(address(this), _usdtAddress);
        pairs[pair2] = true;
        pairsEnabled[pair2] = true; // PIJS交易对默认开启
        wethAddress = _wethAddress;
        operator = _operator;
        manageContract = _manageContract;
        usdtAddress = _usdtAddress;
        _name = tokenName;
        _symbol = tokenSymbol;
        _mint(_receiver, mintAmount * 10 ** decimals());
        
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
    }

    modifier onlyOperater(){
        require(msg.sender == operator,"Only operator can do");
        _;
    }
   
    function updateGlobalBuyWhitelist(address _account, bool _status) external onlyOwner {
        globalBuyWhitelist[_account] = _status;
        emit GlobalBuyWhitelistUpdated(_account, _status);
    }
    
    function batchUpdateBuyGlobalWhitelist(address[] calldata _accounts, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            globalBuyWhitelist[_accounts[i]] = _status;
            emit GlobalBuyWhitelistUpdated(_accounts[i], _status);
        }
    }
    function setGlobalSellWhitelist(address _address, bool _state) public onlyOwner {
        require(_address != address(0), "JW:ZERO_ADDRESS");
        globalSellWhitelist[_address] = _state;
    }

    function batchSetGlobalSellWhitelist(
        address[] calldata _address,
        bool _state
    ) public onlyOwner {
        for (uint i = 0; i < _address.length; i++) {
            globalSellWhitelist[_address[i]] = _state;
        }
    }
   
    

    function updateSelTradingEnabled(bool flag) external onlyOwner {
        sellTradingEnabled = flag;
        emit TradingEnabledUpdated(flag);
    } 
    function getSellTradingEnabled() public view returns(bool){
        return sellTradingEnabled;
    }

    function updateBuyTradingEnabled(bool flag) external onlyOwner {
        buyTradingEnabled = flag;
       
    } 
    function getBuyTradingEnabled() public view returns(bool){
        return buyTradingEnabled;
    }

    function updateTransTradingEnabled(bool flag) external onlyOwner {
        transTradingEnabled = flag;
       
    } 
    function getTransTradingEnabled() public view returns(bool){
        return transTradingEnabled;
    }

    function setPair(address _pair, bool _state) public onlyOwner {
        require(_pair != address(0), "JW:ZERO_ADDRESS");
        pairs[_pair] = _state;
    }
    
    function setPairsEnabledStatus(address _pair, bool _state) public onlyOwner {
        require(_pair != address(0), "JW:ZERO_ADDRESS");
        pairsEnabled[_pair] = _state;
        emit PairEnabledStatusUpdated(_pair, _state);
    }
    
    function getPairsEnabledStatus(address _pair) public view returns(bool) {
        return  pairsEnabled[_pair];
    }

    function mint(address to, uint256 amount) external  onlyOperater {
        _mint(to, amount);
    }

    

    
    // === 多个手续费接收者管理函数 ===
    
    
    // 批量设置购买手续费接收者（清空后重新设置）
    function setBuyFeeReceivers(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner {
        require(_receivers.length == _rates.length, "JW: Arrays length mismatch");
        require(_receivers.length > 0, "JW: Empty arrays");
        
        // 检查总费率不超过100%
        uint256 totalRate = 0;
        for (uint256 i = 0; i < _rates.length; i++) {
            // require(_receivers[i] != address(0), "JW: Zero address");
            require(_rates[i] > 0 && _rates[i] <= 10000, "JW: Invalid rate");
            totalRate += _rates[i];
        }
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        // 清空现有设置
        delete buyFeeReceivers;
        
        // 添加新设置
        for (uint256 i = 0; i < _receivers.length; i++) {
            buyFeeReceivers.push(FeeReceiver(_receivers[i], _rates[i]));
            emit BuyFeeReceiverAdded(_receivers[i], _rates[i]);
        }
    }

    function setBuyFeeReceiversNormal(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner {
        require(_receivers.length == _rates.length, "JW: Arrays length mismatch");
        require(_receivers.length > 0, "JW: Empty arrays");
        
        // 检查总费率不超过100%
        uint256 totalRate = 0;
        for (uint256 i = 0; i < _rates.length; i++) {
            // require(_receivers[i] != address(0), "JW: Zero address");
            require(_rates[i] > 0 && _rates[i] <= 10000, "JW: Invalid rate");
            totalRate += _rates[i];
        }
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        // 清空现有设置
        delete buyFeeReceiversNormal;
        
        // 添加新设置
        for (uint256 i = 0; i < _receivers.length; i++) {
            buyFeeReceiversNormal.push(FeeReceiver(_receivers[i], _rates[i]));
            emit BuyFeeReceiverAddedNormal(_receivers[i], _rates[i]);
        }
    }

    function setTradeProfitNormal(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner {
        require(_receivers.length == _rates.length, "JW: Arrays length mismatch");
        require(_receivers.length > 0, "JW: Empty arrays");
        
        // 检查总费率不超过100%
        uint256 totalRate = 0;
        for (uint256 i = 0; i < _rates.length; i++) {
            // require(_receivers[i] != address(0), "JW: Zero address");
            require(_rates[i] > 0 && _rates[i] <= 10000, "JW: Invalid rate");
            totalRate += _rates[i];
        }
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        // 清空现有设置
        delete tradeProfitNormal;
        
        // 添加新设置
        for (uint256 i = 0; i < _receivers.length; i++) {
            tradeProfitNormal.push(FeeReceiver(_receivers[i], _rates[i]));
        }
    }
    
    // 批量设置出售手续费接收者（清空后重新设置）
    function setSellFeeReceivers(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner {
        require(_receivers.length == _rates.length, "JW: Arrays length mismatch");
        require(_receivers.length > 0, "JW: Empty arrays");
        
        // 检查总费率不超过100%
        uint256 totalRate = 0;
        for (uint256 i = 0; i < _rates.length; i++) {
            // require(_receivers[i] != address(0), "JW: Zero address");
            require(_rates[i] > 0 && _rates[i] <= 10000, "JW: Invalid rate");
            totalRate += _rates[i];
        }
        require(totalRate <= 10000, "JW: Total sell fee rate exceeds 100%");
        
        // 清空现有设置
        delete sellFeeReceivers;
        
        // 添加新设置
        for (uint256 i = 0; i < _receivers.length; i++) {
            sellFeeReceivers.push(FeeReceiver(_receivers[i], _rates[i]));
            emit SellFeeReceiverAdded(_receivers[i], _rates[i]);
        }
    }

    // 批量设置出售手续费接收者（清空后重新设置）
    function setSellFeeReceiversNormal(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner {
        require(_receivers.length == _rates.length, "JW: Arrays length mismatch");
        require(_receivers.length > 0, "JW: Empty arrays");
        
        // 检查总费率不超过100%
        uint256 totalRate = 0;
        for (uint256 i = 0; i < _rates.length; i++) {
            // require(_receivers[i] != address(0), "JW: Zero address");
            require(_rates[i] > 0 && _rates[i] <= 10000, "JW: Invalid rate");
            totalRate += _rates[i];
        }
        require(totalRate <= 10000, "JW: Total sell fee rate exceeds 100%");
        
        // 清空现有设置
        delete sellFeeReceiversNormal;
        
        // 添加新设置
        for (uint256 i = 0; i < _receivers.length; i++) {
            sellFeeReceiversNormal.push(FeeReceiver(_receivers[i], _rates[i]));
            emit SellFeeReceiverAddedNormal(_receivers[i], _rates[i]);
        }
    }
    
    
    // 清空所有购买手续费接收者
    function clearAllBuyFeeReceivers() external onlyOwner {
        delete buyFeeReceivers;
    }

    function clearAllBuyFeeReceiversNormal() external onlyOwner {
        delete buyFeeReceiversNormal;
    }
    
    
    // 清空所有出售手续费接收者
    function clearAllSellFeeReceivers() external onlyOwner {
        delete sellFeeReceivers;
    }
    function clearAllSellFeeReceiversNormal() external onlyOwner {
        delete sellFeeReceiversNormal;
    }
    
    
    // 添加购买手续费接收者
    function addBuyFeeReceiver(address _receiver, uint256 _rate) external onlyOwner {
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate"); // 最大100%
        
        // 检查总费率不超过100%
        uint256 totalRate = _getTotalBuyFeeRate() + _rate;
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        buyFeeReceivers.push(FeeReceiver(_receiver, _rate));
        emit BuyFeeReceiverAdded(_receiver, _rate);
    }

    function addBuyFeeReceiverNormal(address _receiver, uint256 _rate) external onlyOwner {
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate"); // 最大100%
        
        // 检查总费率不超过100%
        uint256 totalRate = _getTotalBuyFeeRateNormal() + _rate;
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        buyFeeReceiversNormal.push(FeeReceiver(_receiver, _rate));
        emit BuyFeeReceiverAddedNormal(_receiver, _rate);
    }
    
    // 添加出售手续费接收者
    function addSellFeeReceiver(address _receiver, uint256 _rate) external onlyOwner {
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate"); // 最大100%
        
        // 检查总费率不超过100%
        uint256 totalRate = _getTotalSellFeeRate() + _rate;
        require(totalRate <= 10000, "JW: Total sell fee rate exceeds 100%");
        
        sellFeeReceivers.push(FeeReceiver(_receiver, _rate));
        emit SellFeeReceiverAdded(_receiver, _rate);
    }

    function addSellFeeReceiverNormal(address _receiver, uint256 _rate) external onlyOwner {
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate"); // 最大100%
        
        // 检查总费率不超过100%
        uint256 totalRate = _getTotalSellFeeRateNormal() + _rate;
        require(totalRate <= 10000, "JW: Total sell fee rate exceeds 100%");
        
        sellFeeReceiversNormal.push(FeeReceiver(_receiver, _rate));
        emit SellFeeReceiverAddedNormal(_receiver, _rate);
    }
    
    // 更新购买手续费接收者
    function updateBuyFeeReceiver(uint256 _index, address _receiver, uint256 _rate) external onlyOwner {
        require(_index < buyFeeReceivers.length, "JW: Index out of bounds");
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate");
        
        // 检查总费率不超过100%（排除当前更新的项）
        uint256 totalRate = _getTotalBuyFeeRate() - buyFeeReceivers[_index].rate + _rate;
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        buyFeeReceivers[_index] = FeeReceiver(_receiver, _rate);
        emit BuyFeeReceiverUpdated(_index, _receiver, _rate);
    }

    function updateBuyFeeReceiverNormal(uint256 _index, address _receiver, uint256 _rate) external onlyOwner {
        require(_index < buyFeeReceiversNormal.length, "JW: Index out of bounds");
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate");
        
        // 检查总费率不超过100%（排除当前更新的项）
        uint256 totalRate = _getTotalBuyFeeRateNormal() - buyFeeReceiversNormal[_index].rate + _rate;
        require(totalRate <= 10000, "JW: Total buy fee rate exceeds 100%");
        
        buyFeeReceiversNormal[_index] = FeeReceiver(_receiver, _rate);
        emit BuyFeeReceiverUpdated(_index, _receiver, _rate);
    }
    
    // 更新出售手续费接收者
    function updateSellFeeReceiver(uint256 _index, address _receiver, uint256 _rate) external onlyOwner {
        require(_index < sellFeeReceivers.length, "JW: Index out of bounds");
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate");
        
        // 检查总费率不超过100%（排除当前更新的项）
        uint256 totalRate = _getTotalSellFeeRate() - sellFeeReceivers[_index].rate + _rate;
        require(totalRate <= 10000, "JW: Total sell fee rate exceeds 100%");
        
        sellFeeReceivers[_index] = FeeReceiver(_receiver, _rate);
        emit SellFeeReceiverUpdated(_index, _receiver, _rate);
    }

    function updateSellFeeReceiverNormal(uint256 _index, address _receiver, uint256 _rate) external onlyOwner {
        require(_index < sellFeeReceiversNormal.length, "JW: Index out of bounds");
        // require(_receiver != address(0), "JW: Zero address");
        require(_rate > 0 && _rate <= 10000, "JW: Invalid rate");
        
        // 检查总费率不超过100%（排除当前更新的项）
        uint256 totalRate = _getTotalSellFeeRateNormal() - sellFeeReceiversNormal[_index].rate + _rate;
        require(totalRate <= 10000, "JW: Total sell fee rate exceeds 100%");
        
        sellFeeReceiversNormal[_index] = FeeReceiver(_receiver, _rate);
        emit SellFeeReceiverUpdatedNormal(_index, _receiver, _rate);
    }
    
    
    // 删除购买手续费接收者
    function removeBuyFeeReceiver(uint256 _index) external onlyOwner {
        require(_index < buyFeeReceivers.length, "JW: Index out of bounds");
        buyFeeReceivers[_index] = buyFeeReceivers[buyFeeReceivers.length - 1];
        buyFeeReceivers.pop();
        emit BuyFeeReceiverRemoved(_index);
    }
    function removeBuyFeeReceiverNormal(uint256 _index) external onlyOwner {
        require(_index < buyFeeReceiversNormal.length, "JW: Index out of bounds");
        buyFeeReceiversNormal[_index] = buyFeeReceiversNormal[buyFeeReceiversNormal.length - 1];
        buyFeeReceiversNormal.pop();
        emit BuyFeeReceiverRemovedNormal(_index);
    }
    
    // 删除出售手续费接收者
    function removeSellFeeReceiver(uint256 _index) external onlyOwner {
        require(_index < sellFeeReceivers.length, "JW: Index out of bounds");
        sellFeeReceivers[_index] = sellFeeReceivers[sellFeeReceivers.length - 1];
        sellFeeReceivers.pop();
        emit SellFeeReceiverRemoved(_index);
    }
    function removeSellFeeReceiverNormal(uint256 _index) external onlyOwner {
        require(_index < sellFeeReceiversNormal.length, "JW: Index out of bounds");
        sellFeeReceiversNormal[_index] = sellFeeReceiversNormal[sellFeeReceiversNormal.length - 1];
        sellFeeReceiversNormal.pop();
        emit SellFeeReceiverRemoved(_index);
    }
    
    
    // 获取购买手续费接收者数量
    function getBuyFeeReceiversCount() external view returns (uint256) {
        return buyFeeReceivers.length;
    }
    function getBuyFeeReceiversCountNormal() external view returns (uint256) {
        return buyFeeReceiversNormal.length;
    }
    
    
    // 获取出售手续费接收者数量
    function getSellFeeReceiversCount() external view returns (uint256) {
        return sellFeeReceivers.length;
    }
    function getSellFeeReceiversCountNormal() external view returns (uint256) {
        return sellFeeReceiversNormal.length;
    }
    
    // === 查询函数 ===
    
    // 获取购买手续费接收者信息
    function getBuyFeeReceiver(uint256 _index) external view returns (address receiver, uint256 rate) {
        require(_index < buyFeeReceivers.length, "JW: Index out of bounds");
        FeeReceiver memory feeReceiver = buyFeeReceivers[_index];
        return (feeReceiver.receiver, feeReceiver.rate);
    }
    function getBuyFeeReceiverNormal(uint256 _index) external view returns (address receiver, uint256 rate) {
        require(_index < buyFeeReceiversNormal.length, "JW: Index out of bounds");
        FeeReceiver memory feeReceiver = buyFeeReceiversNormal[_index];
        return (feeReceiver.receiver, feeReceiver.rate);
    }
    
    // 获取出售手续费接收者信息
    function getSellFeeReceiver(uint256 _index) external view returns (address receiver, uint256 rate) {
        require(_index < sellFeeReceivers.length, "JW: Index out of bounds");
        FeeReceiver memory feeReceiver = sellFeeReceivers[_index];
        return (feeReceiver.receiver, feeReceiver.rate);
    }
    function getSellFeeReceiverNormal(uint256 _index) external view returns (address receiver, uint256 rate) {
        require(_index < sellFeeReceiversNormal.length, "JW: Index out of bounds");
        FeeReceiver memory feeReceiver = sellFeeReceiversNormal[_index];
        return (feeReceiver.receiver, feeReceiver.rate);
    }
    
    // 获取所有购买手续费接收者
    function getAllBuyFeeReceivers() external view returns (FeeReceiver[] memory) {
        return buyFeeReceivers;
    }
    function getAllBuyFeeReceiversNormal() external view returns (FeeReceiver[] memory) {
        return buyFeeReceiversNormal;
    }

    function getAllTradeProfitNormal() external view returns (FeeReceiver[] memory) {
        return tradeProfitNormal;
    }
    
    // 获取所有出售手续费接收者
    function getAllSellFeeReceivers() external view returns (FeeReceiver[] memory) {
        return sellFeeReceivers;
    }
    function getAllSellFeeReceiversNormal() external view returns (FeeReceiver[] memory) {
        return sellFeeReceiversNormal;
    }
    
    // 检查是否为全局白名单用户
    function isGlobalBuyWhitelisted(address _account) external view returns (bool) {
        return globalBuyWhitelist[_account];
    }
   
    // 获取总购买手续费率
    function getTotalBuyFeeRate() external view returns (uint256) {
        return _getTotalBuyFeeRate();
    }
    function getTotalBuyFeeRateNormal() external view returns (uint256) {
        return _getTotalBuyFeeRateNormal();
    }
    
    
    // 获取总出售手续费率
    function getTotalSellFeeRate() external view returns (uint256) {
        return _getTotalSellFeeRate();
    }
    function getTotalSellFeeRateNormal() external view returns (uint256) {
        return _getTotalSellFeeRateNormal();
    }
    
    // 内部函数：计算总购买手续费率
    function _getTotalBuyFeeRate() internal view returns (uint256) {
        uint256 totalRate = 0;
        for (uint256 i = 0; i < buyFeeReceivers.length; i++) {
            totalRate += buyFeeReceivers[i].rate;
        }
        return totalRate;
    }

    function _getTotalBuyFeeRateNormal() internal view returns (uint256) {
        uint256 totalRate = 0;
        for (uint256 i = 0; i < buyFeeReceiversNormal.length; i++) {
            totalRate += buyFeeReceiversNormal[i].rate;
        }
        return totalRate;
    }
    
    // 内部函数：计算总出售手续费率
    function _getTotalSellFeeRate() internal view returns (uint256) {
        uint256 totalRate = 0;
        for (uint256 i = 0; i < sellFeeReceivers.length; i++) {
            totalRate += sellFeeReceivers[i].rate;
        }
        return totalRate;
    }
    function _getTotalSellFeeRateNormal() internal view returns (uint256) {
        uint256 totalRate = 0;
        for (uint256 i = 0; i < sellFeeReceiversNormal.length; i++) {
            totalRate += sellFeeReceiversNormal[i].rate;
        }
        return totalRate;
    }

    function setTradeToPublic(bool _tradeToPublic) public onlyOwner {
        tradeToPublic = _tradeToPublic;
    }
    


   function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        // 检查交易是否整体开放
        require(tradeToPublic, "JW: not open");
         /* ================= 买入限制 买入收税 ================= */
        if (pairs[from]){
            if (globalBuyWhitelist[from] || globalBuyWhitelist[to]) {
                _standardTransfer(from, to, amount);
            }  else {
                if (buyLimitAddressSwitch){
                    require(buyLimitAddressWhitelist[to] , "JW: buy restricted");
                    require(buyTradingEnabled,"JW: tradingEnabled not enable");
                    _swapTransfer(from, to, amount); 
                } else {
                    if (buyLimitAddressWhitelist[to]){
                        require(buyTradingEnabled,"JW: tradingEnabled not enable");
                        _swapTransfer(from, to, amount); 
                    } else {
                        require(buyTradingEnabled,"JW: tradingEnabled not enable");
                        
                       
                        _swapTransferNormal(from, to, amount); 
                    }
                }
            }  
        } else if (pairs[to]){ /* ================= 卖出收税================= */
            require(sellTradingEnabled,"JW: tradingEnabled not enable");
            if (globalSellWhitelist[from]) {
                _standardTransfer(from, to, amount); 
            } else {
                if (sellLimitAddressSwitch){
                    require(sellLimitAddressWhitelist[from], "JW: sell restricted");
                    require(sellTradingEnabled,"JW: tradingEnabled not enable");
                    _swapTransfer(from, to, amount); 
                } else {
                    if (sellLimitAddressWhitelist[from]){
                        require(sellTradingEnabled,"JW: tradingEnabled not enable");
                        _swapTransfer(from, to, amount); 
                    } else {
                        require(sellTradingEnabled,"JW: tradingEnabled not enable");
                        _swapTransferNormal(from, to, amount); 
                    }
                }
            }
            
        } else {
            require(transTradingEnabled,"JW: tradingEnabled not enable");
            _standardTransfer(from, to, amount); 
        }
        _afterTokenTransfer(from, to, amount);
    }

    function _standardTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _swapTransfer(address from, address to, uint256 amount) internal {
        if (pairs[from]) {
            // buy - 从 swap 中购买
            uint256 totalFeeAmount = 0;
            if (buyFeeReceivers.length > 0) {
                // 使用多个手续费接收者
                for (uint256 i = 0; i < buyFeeReceivers.length; i++) {
                    uint256 feeAmount = (amount * buyFeeReceivers[i].rate) / 10000;
                        if (feeAmount > 0) {
                            _standardTransfer(from, buyFeeReceivers[i].receiver, feeAmount);
                            totalFeeAmount += feeAmount;
                        }
                }
            }
            uint256 transferAmount = amount - totalFeeAmount;
            _standardTransfer(from, to, transferAmount);
        } else {
            // sell - 卖出到 swap
            uint256 totalFeeAmount = 0;
            if (sellFeeReceivers.length > 0) {
                // 使用多个手续费接收者
                for (uint256 i = 0; i < sellFeeReceivers.length; i++) {
                    uint256 feeAmount = (amount * sellFeeReceivers[i].rate) / 10000;
                        if (feeAmount > 0) {
                            _standardTransfer(from, sellFeeReceivers[i].receiver, feeAmount);
                            totalFeeAmount += feeAmount;
                        } 
                }
            }

            uint256 transferAmount = amount - totalFeeAmount;
            
            _standardTransfer(from, to, transferAmount);
        }
    }

    function _swapTransferNormal(address from, address to, uint256 amount) internal {
        if (pairs[from]) {
            // buy - 从 swap 中购买
            uint256 totalFeeAmount = 0;
            if (buyFeeReceiversNormal.length > 0) {
                // 使用多个手续费接收者
                for (uint256 i = 0; i < buyFeeReceiversNormal.length; i++) {
                    uint256 feeAmount = (amount * buyFeeReceiversNormal[i].rate) / 10000;
                        if (feeAmount > 0) {
                            _standardTransfer(from, buyFeeReceiversNormal[i].receiver, feeAmount);
                            totalFeeAmount += feeAmount;
                        }
                }
            }
            uint256 transferAmount = amount - totalFeeAmount;
            // 买入加仓
           // uint256 pijsAmountWithOutFee = getJW2PIJS(transferAmount);
            uint256 usdtAmount = getJW2USDT(amount);
            userSwapNormals[to].totalHoldings +=  transferAmount;
            userSwapNormals[to].totalCost +=  usdtAmount;

            _standardTransfer(from, to, transferAmount);
        } else {
            // sell - 卖出到 swap
            uint256 totalFeeAmount = 0;
            if (sellFeeReceiversNormal.length > 0) {
                // 使用多个手续费接收者
                for (uint256 i = 0; i < sellFeeReceiversNormal.length; i++) {
                    uint256 feeAmount = (amount * sellFeeReceiversNormal[i].rate) / 10000;
                    if (feeAmount > 0) {
                        _standardTransfer(from, sellFeeReceiversNormal[i].receiver, feeAmount);
                        totalFeeAmount += feeAmount;
                    } 
                }
            }
           
            // 减仓
            UserSwapNormal storage user = userSwapNormals[from];
            // 卖出的成本
            uint256 sellCost = 0;
            // 卖出的jw
            uint256 sellAmountFromCost = 0;

            if (user.totalHoldings > 0) {
                sellAmountFromCost = amount > user.totalHoldings 
                    ? user.totalHoldings 
                    : amount;

                uint256 unitCost = user.totalCost * 1e18 / user.totalHoldings;
                sellCost = unitCost * sellAmountFromCost / 1e18;

                user.totalHoldings -= sellAmountFromCost;
                // 当减仓为0时，成本可能有残留
                if (user.totalHoldings == 0){
                    user.totalCost  = 0;
                } else {
                    user.totalCost -= sellCost;
                }
            }

            // 最终利润
            uint256 profitAmount = 0;
            uint256 profitDistribute = 0;
            uint256 sellAmountFromCostPijsValue = 0;
            if (sellAmountFromCost > 0){
                sellAmountFromCostPijsValue = getJW2USDT(sellAmountFromCost);
            }
            if (sellAmountFromCostPijsValue > sellCost) {
                profitAmount = sellAmountFromCostPijsValue - sellCost;
                uint256 profitJWAmount = getUSDT2JW(profitAmount);
                // 对利润进行分配
                for (uint256 i = 0; i < tradeProfitNormal.length; i++) {
                    uint256 feeAmount = (profitJWAmount * tradeProfitNormal[i].rate) / 10000;
                    if (feeAmount > 0) {
                        _standardTransfer(from, tradeProfitNormal[i].receiver, feeAmount);
                        emit ProfitDistribute(from,to,feeAmount,block.timestamp);
                        profitDistribute += feeAmount;
                    } 
                }
            }

            uint256 transferAmount = amount - totalFeeAmount - profitDistribute;
            _standardTransfer(from, to, transferAmount);
        }
    }

   
    
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }


    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {} 

    // 设置入金合约地址
    function setManageContract(address _manageContract) public onlyOwner {
        require(_manageContract != address(0),"0 address invalid");
        manageContract = _manageContract;
    }
    
    receive() external payable {}

    function transferFromContract(address to, uint256 amount) external  {
        require(msg.sender == manageContract,"only manage contract can do");
        _transfer(address(this), to, amount);
    }

    function setLimitAddressSwitch(bool _sellLimitAddressSwitch,bool _buyLimitAddressSwitch) public onlyOwner {
        sellLimitAddressSwitch = _sellLimitAddressSwitch;
        buyLimitAddressSwitch = _buyLimitAddressSwitch;

    }

    function setSellLimitAddressWhitelist(address seller,bool isOpen) public onlyOwner {
        sellLimitAddressWhitelist[seller] = isOpen;
    }

    function setBuyLimitAddressWhitelist(address buyer,bool isOpen) public onlyOwner {
        buyLimitAddressWhitelist[buyer] = isOpen;
    }

    function getJW2PIJS(uint256 jwAmount) public view returns(uint256) {
            IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
            // jw-> pijs
            address[] memory path2 = new address[](2);
            path2[0] = address(this);
            path2[1] = swapRouter.WETH();

            uint[] memory amounts2 = swapRouter.getAmountsOut(jwAmount, path2);
            uint256 pijsAmount = amounts2[1];
            require(pijsAmount > 0, "jw -> pijs quote failed");
            
            return pijsAmount;
    }

    function getJW2USDT(uint256 jwAmount) public view returns(uint256) {
            IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
            // jw-> usdt
            address[] memory path2 = new address[](2);
            path2[0] = address(this);
            path2[1] = usdtAddress;

            uint[] memory amounts2 = swapRouter.getAmountsOut(jwAmount, path2);
            uint256 pijsAmount = amounts2[1];
            require(pijsAmount > 0, "jw -> usdt quote failed");
            
            return pijsAmount;
    }

    function getPIJS2JW(uint256 pijsAmount) public view returns(uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);

        // pijs -> jw
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = address(this);

        uint[] memory amounts2 = swapRouter.getAmountsOut(pijsAmount, path2);
        uint256 jwAmount = amounts2[1];
        require(jwAmount > 0, "pijs -> jw quote failed");
        
        return jwAmount;
    }

    function getUSDT2JW(uint256 pijsAmount) public view returns(uint256) {
        
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = usdtAddress;

        uint[] memory amounts2 = swapRouter.getAmountsOut(pijsAmount, path2);
        uint256 jwAmount = amounts2[1];
        require(jwAmount > 0, "usdt ->  pijs quote failed");
        
        return jwAmount;
    }

    function getUserSwapNormals(address user) public view returns(UserSwapNormal memory){
        return userSwapNormals[user];
    }



}
