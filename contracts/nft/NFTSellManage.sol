// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interface/INFTSell.sol";
contract NFTSellManage is  Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable {
        bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");
        bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");
        /// @custom:oz-upgrades-unsafe-allow constructor
        constructor() {
            _disableInitializers();
        }

        function _authorizeUpgrade(
            address newImplementation
        ) internal override onlyRole(MANAGE_ROLE) {}

        function initialize(
            address _usdtAddress,
            address _receiver,
            address _recommandContractAddress,
            address _swapRouterAddress,
            address _jwToken,
            address[3] memory nftaddresses,
            uint256[3] memory jwUSDTPrices,
            uint256[3] memory pijsUSDTPrices,
            uint8[3] memory limits
        ) public initializer {
            __AccessControlEnumerable_init();
            __ReentrancyGuard_init();
            __UUPSUpgradeable_init();
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MANAGE_ROLE, msg.sender);

            usdtAddress = _usdtAddress;
            receiver = _receiver;
            recommandContractAddress = _recommandContractAddress;
            swapRouterAddress = _swapRouterAddress;
            jwToken = _jwToken;

            // init product
            NFTProduct memory platinunNft = NFTProduct(
                {
                    nftAddr : nftaddresses[0],
                    jwUSDTPrice : jwUSDTPrices[0],
                    pijsUSDTPrice : pijsUSDTPrices[0],
                    limit : limits[0]
                }
            ); 
            NFTProduct memory epicNft = NFTProduct(
                {
                    nftAddr : nftaddresses[1],
                    jwUSDTPrice : jwUSDTPrices[1],
                    pijsUSDTPrice : pijsUSDTPrices[1],
                    limit : limits[1]
                }
            ); 
            NFTProduct memory legendNft = NFTProduct(
                {
                    nftAddr : nftaddresses[2],
                    jwUSDTPrice : jwUSDTPrices[2],
                    pijsUSDTPrice : pijsUSDTPrices[2],
                    limit : limits[2]
                }
            ); 

            products[nftaddresses[0]] = platinunNft;
            products[nftaddresses[1]] = epicNft;
            products[nftaddresses[2]] = legendNft;



        }

    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    /////////////////////////////////////////////////////////////*/
    address usdtAddress;
    address receiver;
    address recommandContractAddress;
    address swapRouterAddress;
    address jwToken;
    mapping(address => uint256) userNfts;
    uint256 public currentNftId;

    // Product
    struct NFTProduct {
       address nftAddr;
       uint256 jwUSDTPrice;
       uint256 pijsUSDTPrice;
       uint8 limit;
    }
    mapping(address => NFTProduct) products;

    // Order
    struct Order {
        uint256 orderId;
        address product;
        uint256 nftId;
        uint256 buyJwUsdtAmount;
        uint256 buyPijsUsdtAmount;
        uint256 purchasedJwAmount;
        uint256 purchasedPIJSAmount;
        uint256 timestamp;
    }
    mapping(uint256 => Order) orders;
    mapping(address => uint256[]) userOrderIds;
    mapping(uint256 => uint256[]) ordersPerDay;

    // 交易量
    // 个人日交易额
    mapping(address => mapping(uint256 => uint256)) userTradePerDay;
    // 个人总交易额
    mapping(address => uint256) userTradeTotal;
    // 平台日交易量
    mapping(uint256 => uint256) platformTradePerDay;
    // 平台总交易量
    uint256 platformTradeTotal;
    
    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 orderId;

    
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event  BuyNFT(address user,uint256 buyJwAmount,uint256 buyPIJSAmount,address nftAddress,uint256 nftId,
        uint256 dayIndex,uint256 currentOrderId,uint256 purchasedJwAmount,uint256 purchasedPIJSAmount,uint256 userTradeTotalAmount,
        uint256 userTradePerDayAmount,uint256 platformTradeTotalAmount,uint256 platformTradePerDayAmount,uint256 createTime);

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function buyNFT(uint256 buyJwAmount,uint256 buyPIJSAmount,address nftAddress) public payable nonReentrant {
        require(buyJwAmount > 0,"buyJwAmount is 0");
        require(products[nftAddress].nftAddr != address(0),"nft product is not exist");
        require(buyPIJSAmount > 0,"buyPIJSAmount is 0");
        require(buyJwAmount >= products[nftAddress].jwUSDTPrice,"jw's usdt value is less than the price");
        require(buyPIJSAmount >= products[nftAddress].pijsUSDTPrice,"pijs's usdt value is less than the price");
        uint256 createTime = block.timestamp;
        // validate recommand
        (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
        require(referrer != address(0),"user is not recommanded");
        // buy JW
        uint256 purchasedJwAmount = usdtBuyJW(buyJwAmount);
        // buy PIJS
        uint256 purchasedPIJSAmount = usdtBuyPIJS(buyPIJSAmount);

        // transfer 
        SafeERC20.safeTransferFrom(IERC20(jwToken), address(this),msg.sender, purchasedJwAmount);
        (bool ok, ) = msg.sender.call{value: purchasedPIJSAmount}("");
        require(ok, "msg sender received pijs transfer failed");
        // mint nft
        uint256 nftId = INFT(nftAddress).mint(msg.sender);
        // update
        require(orders[orderId].product == address(0),"order is exist");
        Order memory order = Order({
            orderId:orderId,
            product:nftAddress,
            nftId :nftId,
            buyJwUsdtAmount:buyJwAmount,
            buyPijsUsdtAmount:buyPIJSAmount,
            purchasedJwAmount:purchasedJwAmount,
            purchasedPIJSAmount:purchasedPIJSAmount,
            timestamp:createTime
        });
        uint256 dayIndex = getDayIndex(createTime);
        orders[orderId] = order;
        userOrderIds[msg.sender].push(orderId);
        ordersPerDay[dayIndex].push(orderId);
        uint256 currentOrderId = orderId;
        orderId = orderId + 1;
        userTradeTotal[msg.sender] = userTradeTotal[msg.sender] + buyJwAmount + buyPIJSAmount;
        userTradePerDay[msg.sender] [dayIndex]=  userTradePerDay[msg.sender][dayIndex] + buyJwAmount + buyPIJSAmount;
        platformTradeTotal = platformTradeTotal + buyJwAmount + buyPIJSAmount;
        platformTradePerDay[dayIndex] = platformTradePerDay[dayIndex] + buyJwAmount + buyPIJSAmount;
        
        emit BuyNFT(msg.sender,buyJwAmount,buyPIJSAmount,nftAddress,nftId,
        dayIndex,currentOrderId,purchasedJwAmount,purchasedPIJSAmount,userTradeTotal[msg.sender],
        userTradePerDay[msg.sender] [dayIndex],platformTradeTotal,platformTradePerDay[dayIndex],createTime);
    }
    function usdtBuyPIJS(uint256 buyPIJSAmount) internal returns(uint256){
        // 1. 先从用户拉 USDT
        SafeERC20.safeTransferFrom(IERC20(usdtAddress), msg.sender, address(this), buyPIJSAmount);
        // 2. 再授权 Router
        SafeERC20.safeApprove(IERC20(usdtAddress), swapRouterAddress, 0);
        SafeERC20.safeApprove(IERC20(usdtAddress),swapRouterAddress, buyPIJSAmount);
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // 2. USDT -> WETH
        address[] memory path1 = new address[](2);
        path1[0] = usdtAddress;
        path1[1] = swapRouter.WETH();
        
        uint256 beforeETHBalance = address(this).balance;
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            buyPIJSAmount,
            0,
            path1,
            address(this),
            block.timestamp + 300
        );
        uint256 afterETHBalance = address(this).balance;
        return afterETHBalance - beforeETHBalance;
    }

    function usdtBuyJW(uint256 buyJwAmount) internal returns(uint256){
         // 1. 先从用户拉 USDT
        SafeERC20.safeTransferFrom(IERC20(usdtAddress), msg.sender, address(this), buyJwAmount);
        // 2. 再授权 Router
        SafeERC20.safeApprove(IERC20(usdtAddress), swapRouterAddress, 0);
        SafeERC20.safeApprove(IERC20(usdtAddress),swapRouterAddress, buyJwAmount);
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // 3. USDT -> WETH
        address[] memory path1 = new address[](2);
        path1[0] = usdtAddress;
        path1[1] = swapRouter.WETH();
        
        uint256 beforeETHBalance = address(this).balance;
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            buyJwAmount,
            0,
            path1,
            address(this),
            block.timestamp + 300
        );
        uint256 afterETHBalance = address(this).balance;
        uint256 ethReceived = afterETHBalance - beforeETHBalance;
        // WETH -> JW
        uint256 beforeJWAmount = IERC20(jwToken).balanceOf(address(this));
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = jwToken;
        swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethReceived}(
            0,
            path2,
            address(this),
            block.timestamp + 300
        );
        uint256 afterJWAmount = IERC20(jwToken).balanceOf(address(this));

        uint256 jwReceived = afterJWAmount - beforeJWAmount;

        return jwReceived;
    }

    function getDayIndex(uint256 timePerSecond) public pure returns (uint256) {
        return timePerSecond / SECONDS_PER_DAY;
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS   setter  getter
    //////////////////////////////////////////////////////////////*/
    function setProduct(address[3] memory nftaddress,
            uint256[3] memory jwUSDTPrices,
            uint256[3] memory pijsUSDTPrices,
            uint8[3] memory limits) external onlyRole(MANAGE_ROLE) {
            NFTProduct memory platinunNft = NFTProduct(
                {
                    nftAddr : nftaddress[0],
                    jwUSDTPrice : jwUSDTPrices[0],
                    pijsUSDTPrice : pijsUSDTPrices[0],
                    limit : limits[0]
                }
            ); 
            NFTProduct memory epicNft = NFTProduct(
                {
                    nftAddr : nftaddress[1],
                    jwUSDTPrice : jwUSDTPrices[1],
                    pijsUSDTPrice : pijsUSDTPrices[1],
                    limit : limits[1]
                }
            ); 
            NFTProduct memory legendNft = NFTProduct(
                {
                    nftAddr : nftaddress[2],
                    jwUSDTPrice : jwUSDTPrices[2],
                    pijsUSDTPrice : pijsUSDTPrices[2],
                    limit : limits[2]
                }
            ); 

            products[nftaddress[0]] = platinunNft;
            products[nftaddress[1]] = epicNft;
            products[nftaddress[2]] = legendNft;
    }
    function getProduct(address productAddress) public view  returns(NFTProduct memory){
        return products[productAddress];
    }
    function setParas(address _usdtAddress,
            address _receiver,
            address _recommandContractAddress) public onlyRole(MANAGE_ROLE) {
                usdtAddress = _usdtAddress;
                receiver = _receiver;
                recommandContractAddress = _recommandContractAddress;

    }
    function getParas() public view returns(address,address,address){
        return(usdtAddress,receiver,recommandContractAddress);
    }

    function getPIJS2USDT(uint256 amount) public view returns(uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // pijs-> usdt
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = usdtAddress;

        uint[] memory amounts2 = swapRouter.getAmountsOut(amount, path2);
        uint256 usdtAmount = amounts2[1];
        require(usdtAmount > 0, "pijs->USDT quote failed");
        
        return usdtAmount;
    }

    function getJW2USDT(uint256 infoAmount) public view returns(uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // jw -> pijs
        address[] memory path1 = new address[](2);
        path1[0] = jwToken;
        path1[1] = swapRouter.WETH();
        uint[] memory amounts1 = swapRouter.getAmountsOut(infoAmount, path1);
        uint256 bnbAmount = amounts1[1];
        require(bnbAmount > 0, "jw->pijs quote failed");
        // pijs -> jw
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = usdtAddress;

        uint[] memory amounts2 = swapRouter.getAmountsOut(bnbAmount, path2);
        uint256 usdtAmount = amounts2[1];
        require(usdtAmount > 0, "pijs->USDT quote failed");
        
        return usdtAmount;
    }

    function getUSDT2JW(uint256 usdtAmount) internal view returns(uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // usdt -> pijs
        address[] memory path1 = new address[](2);
        path1[0] = usdtAddress;
        path1[1] = swapRouter.WETH();
        uint[] memory amounts1 = swapRouter.getAmountsOut(usdtAmount, path1);
        uint256 bnbAmount = amounts1[1];
        require(bnbAmount > 0, "USDT->pijs quote failed");

        // pijs -> jw
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = jwToken;
        uint[] memory amounts2 = swapRouter.getAmountsOut(bnbAmount, path2);
        uint256 infoAmount = amounts2[1];
        require(infoAmount > 0, "pijs->jw quote failed");

        return infoAmount;
    }

    function getOrder(uint256 _orderId) public view returns(Order memory) {
        return orders[_orderId];
    }
    function getUserOrderIds(address user) public view returns (uint256[] memory){
        return userOrderIds[user];
    }
    function getUserTradeTotal(address user) public view returns(uint256) {
        return userTradeTotal[user];
    }
    function getUserTradePerDay(address user,uint256 dayIndex) public view returns(uint256) {
        return userTradePerDay[user][dayIndex];
    }
    function getPlatformTradeTotal() public view returns(uint256){
        return platformTradeTotal;
    }
    function getPlatformTradePerDay(uint256 dayIndex) public view returns(uint256) {
        return platformTradePerDay[dayIndex];
    }







}