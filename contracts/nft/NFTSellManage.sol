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
            address operator,
            address _usdtAddress,
            address _receiver,
            address _recommandContractAddress,
            address _swapRouterAddress,
            address _swapOrangeRouterAddress,
            address _jwToken,
            address[3] memory nftaddresses,
            uint256[3] memory usdtPrice,
            uint8[3] memory limits,
            uint256 _wearRate
        ) public initializer {
            __AccessControlEnumerable_init();
            __ReentrancyGuard_init();
            __UUPSUpgradeable_init();
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MANAGE_ROLE, msg.sender);
            _grantRole(OPERATE_ROLE, operator);

            usdtAddress = _usdtAddress;
            receiver = _receiver;
            recommandContractAddress = _recommandContractAddress;
            swapRouterAddress = _swapRouterAddress;
            swapOrangeRouterAddress = _swapOrangeRouterAddress;
            jwToken = _jwToken;

            // init product
            NFTProduct memory platinunNft = NFTProduct(
                {
                    nftAddr : nftaddresses[0],
                    usdtPrice : usdtPrice[0],
                    limit : limits[0]
                }
            ); 
            NFTProduct memory epicNft = NFTProduct(
                {
                    nftAddr : nftaddresses[1],
                    usdtPrice : usdtPrice[1],
                    limit : limits[1]
                }
            ); 
            NFTProduct memory legendNft = NFTProduct(
                {
                    nftAddr : nftaddresses[2],
                    usdtPrice : usdtPrice[2],
                    limit : limits[2]
                }
            ); 

            products[nftaddresses[0]] = platinunNft;
            products[nftaddresses[1]] = epicNft;
            products[nftaddresses[2]] = legendNft;

            wearRate = _wearRate;



        }

    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    /////////////////////////////////////////////////////////////*/
    address usdtAddress;
    address receiver;
    address recommandContractAddress;
    address swapRouterAddress;
    address swapOrangeRouterAddress;
    address jwToken;
    mapping(address => uint256) userNfts;
    uint256 public currentNftId;

    // Product
    struct NFTProduct {
       address nftAddr;
       uint256 usdtPrice;
       uint8 limit;
    }
    mapping(address => NFTProduct) products;

    // Order
    struct Order {
        uint256 orderId;
        address product;
        uint256 nftId;
        uint256 purchasedJwAmount;
        uint256 purchasedPIJSAmount;
        uint256 usdtValue;
        uint256 timestamp;
    }
    mapping(uint256 => Order) orders;
    mapping(address => uint256[]) userOrderIds;
    mapping(uint256 => uint256[]) ordersPerDay;

    
    
    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public constant SECONDS_PER_WEEK = 7 days;
    uint256 public constant SECONDS_PER_YEAR = 7 days;
    uint256 orderId;
    uint256 public wearRate;
    uint256 public constant DENOMINATOR = 1000; 
    struct RewardOrder {
        uint256 weekIndex;
        address user;
        address tokenAddress;
        address nftAddress;
        uint256 nftId;
        uint256 profitSharingAmount;
        uint256 feeSharingAmount;
        uint256 timestamp;
        bool isReceived;
        uint256 receivedTimestamp;
    }
    mapping(address => mapping(uint256 => RewardOrder)) userRewardByWeekOrders;
    mapping(address => mapping(uint256 => uint256[])) userRewardByYearOrders;
    


    
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event  BuyNFT(address user,uint256 buyJwAmount,uint256 buyPIJSAmount,address nftAddress,uint256 nftId,
        uint256 dayIndex,uint256 currentOrderId,uint256 createTime);
    event GenerateRewardOrder(address tokenAddress,uint256 tokenAmount,address nftAddress,uint256 nftId,address nftOwner,uint256 weekIndex,uint256 profitSharingAmount,uint256 feeSharingAmount,uint256 timestamp);
    event ReceiveReward(address user,uint256 nftId,uint256 weekIndex,address nftAddress,uint256 rewardAmount,uint256 timestamp);
    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function buyNFT(uint256 buyJwAmount,uint256 buyPIJSAmount,address jwTokenAddress,uint256 usdtValue,address nftAddress) public payable nonReentrant {
        require(buyJwAmount > 0,"buyJwAmount is 0");
        require(products[nftAddress].nftAddr != address(0),"nft product is not exist");
        require(buyPIJSAmount > 0,"buyPIJSAmount is 0");
        require(usdtValue >= products[nftAddress].usdtPrice,"usdt value is less than the price");
        require(jwTokenAddress == jwToken,"invaild jwTokenAddress");
        require(IERC721(nftAddress).balanceOf(msg.sender) < products[nftAddress].limit,"exceeded the nft limit");
        uint256 createTime = block.timestamp;
        // 判断jw和pijs价值的usdt价值是否
        uint256 buyJwAmount2usd = getJW2USDT(buyJwAmount) ;
        uint256 buyPIJSAmount2usd = getPIJS2USDT(buyPIJSAmount);
        require(buyJwAmount2usd + buyPIJSAmount2usd >= usdtValue * (DENOMINATOR - wearRate)/DENOMINATOR ,"the value of jw and pijs can not reached usdtValue");
        
        // validate recommand
        (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
        require(referrer != address(0),"user is not recommanded");
        // transfer 
        SafeERC20.safeTransferFrom(IERC20(jwToken), msg.sender ,receiver, buyJwAmount);
        (bool ok, ) = receiver.call{value: buyPIJSAmount}("");
        require(ok, "msg sender received pijs transfer failed");
        // mint nft
        uint256 nftId = INFT(nftAddress).mint(msg.sender);
        // update
        require(orders[orderId].product == address(0),"order is exist");
        Order memory order = Order({
            orderId:orderId,
            product:nftAddress,
            nftId :nftId,
            purchasedJwAmount:buyJwAmount,
            purchasedPIJSAmount:buyPIJSAmount,
            usdtValue:usdtValue,
            timestamp:createTime
        });
        uint256 dayIndex = getDayIndex(createTime);
        orders[orderId] = order;
        userOrderIds[msg.sender].push(orderId);
        ordersPerDay[dayIndex].push(orderId);
        uint256 currentOrderId = orderId;
        orderId = orderId + 1;
        
        
        emit BuyNFT(msg.sender,buyJwAmount,buyPIJSAmount,nftAddress,nftId,
        dayIndex,currentOrderId,createTime);
    }
    
    

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS   setter  getter
    //////////////////////////////////////////////////////////////*/
    function getDayIndex(uint256 timePerSecond) public pure returns (uint256) {
        return timePerSecond / SECONDS_PER_DAY;
    }
    function getYearIndex(uint256 timePerSecond) public pure returns (uint256) {
        return 1970 + timePerSecond / SECONDS_PER_YEAR;
    }
    function setProduct(address[3] memory nftaddresses,
        uint256[3] memory usdtPrice,
        uint8[3] memory limits) external onlyRole(MANAGE_ROLE) {
        // init product
        NFTProduct memory platinunNft = NFTProduct(
        {
            nftAddr : nftaddresses[0],
            usdtPrice : usdtPrice[0],
            limit : limits[0]
        }
        ); 
        NFTProduct memory epicNft = NFTProduct(
        {
            nftAddr : nftaddresses[1],
            usdtPrice : usdtPrice[1],
            limit : limits[1]
        }
        ); 
        NFTProduct memory legendNft = NFTProduct(
        {
            nftAddr : nftaddresses[2],
            usdtPrice : usdtPrice[2],
            limit : limits[2]
        }
        ); 

        products[nftaddresses[0]] = platinunNft;
        products[nftaddresses[1]] = epicNft;
        products[nftaddresses[2]] = legendNft;
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
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapOrangeRouterAddress);
        // pijs-> usdt
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = usdtAddress;

        uint[] memory amounts2 = swapRouter.getAmountsOut(amount, path2);
        uint256 usdtAmount = amounts2[1];
        require(usdtAmount > 0, "pijs->USDT quote failed");
        
        return usdtAmount;
    }
    function getUSDT2PIJS(uint256 amount) public view returns(uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapOrangeRouterAddress);
        // pijs-> usdt
        address[] memory path2 = new address[](2);
        path2[0] = usdtAddress;
        path2[1] = swapRouter.WETH();

        uint[] memory amounts2 = swapRouter.getAmountsOut(amount, path2);
        uint256 pijsAmount = amounts2[1];
        require(pijsAmount > 0, "USDT -> pijs quote failed");
        
        return pijsAmount;
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
        
         IUniswapV2Router02 swapOrangeRouter = IUniswapV2Router02(swapOrangeRouterAddress);
        // pijs -> jw
        address[] memory path2 = new address[](2);
        path2[0] = swapOrangeRouter.WETH();
        path2[1] = usdtAddress;

        uint[] memory amounts2 = swapOrangeRouter.getAmountsOut(bnbAmount, path2);
        uint256 usdtAmount = amounts2[1];
        require(usdtAmount > 0, "pijs->USDT quote failed");
        
        return usdtAmount;
    }

    function getUSDT2JW(uint256 usdtAmount) public view returns(uint256) {
        
         IUniswapV2Router02 swapOrangeRouter = IUniswapV2Router02(swapOrangeRouterAddress);
        // usdt -> pijs
        address[] memory path1 = new address[](2);
        path1[0] = usdtAddress;
        path1[1] = swapOrangeRouter.WETH();
        uint[] memory amounts1 = swapOrangeRouter.getAmountsOut(usdtAmount, path1);
        uint256 bnbAmount = amounts1[1];
        require(bnbAmount > 0, "USDT->pijs quote failed");

        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // pijs -> jw
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = jwToken;
        uint[] memory amounts2 = swapRouter.getAmountsOut(bnbAmount, path2);
        uint256 infoAmount = amounts2[1];
        require(infoAmount > 0, "pijs->jw quote failed");

        return infoAmount;
    }

    function getOrder(uint256 _orderId) external view returns(Order memory) {
        return orders[_orderId];
    }
    function getUserOrderIds(address user) external view returns (uint256[] memory){
        return userOrderIds[user];
    }
    
    function setWearRate(uint256 _wearRate) public onlyRole(MANAGE_ROLE) {
        wearRate = _wearRate;
    }

    // 生成奖励记录
    function generateRewardOrder(address tokenAddress,uint256 tokenAmount,address nftAddress,uint256 nftId,address nftOwner,uint256 weekIndex,uint256 profitSharingAmount,uint256 feeSharingAmount) external onlyRole(OPERATE_ROLE) {
        
        
        require(tokenAddress == jwToken,"jw address is invalid");
        require(tokenAmount > 0,"tokenAmount should >0");
        require(products[nftAddress].nftAddr != address(0),"nft address is invalid");
        require(IERC721(nftAddress).ownerOf(nftId) == nftOwner,"the nftid is not owner");
        require(userRewardByWeekOrders[nftOwner][weekIndex].user == address(0),"reward order is not exist");
        RewardOrder memory rOrder = RewardOrder({
            weekIndex : weekIndex,
            user:nftOwner,
            tokenAddress:tokenAddress,
            nftAddress:nftAddress,
            nftId:nftId,
            profitSharingAmount:profitSharingAmount,
            feeSharingAmount:feeSharingAmount,
            timestamp:block.timestamp,
            isReceived:false,
            receivedTimestamp:0
        });
        userRewardByWeekOrders[nftOwner][weekIndex] = rOrder;
        userRewardByYearOrders[nftOwner][getYearIndex(block.timestamp)].push(weekIndex);
        emit GenerateRewardOrder( tokenAddress, tokenAmount, nftAddress, nftId, nftOwner, weekIndex, profitSharingAmount, feeSharingAmount,block.timestamp);
    }

    // 领取奖励
    function receiveReward(uint256 nftId,uint256 weekIndex,address nftAddress) public nonReentrant {
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender,"the nftid is not owner");
        require(userRewardByWeekOrders[msg.sender][weekIndex].user != address(0),"reward order is not exist");
        require(userRewardByWeekOrders[msg.sender][weekIndex].isReceived == false,"reward is received");
        uint256 rewardAmount = userRewardByWeekOrders[msg.sender][weekIndex].profitSharingAmount +  userRewardByWeekOrders[msg.sender][weekIndex].feeSharingAmount;
        SafeERC20.safeTransferFrom(IERC20(jwToken), address(this),msg.sender , rewardAmount);

        userRewardByWeekOrders[msg.sender][weekIndex].isReceived = true;
        userRewardByWeekOrders[msg.sender][weekIndex].receivedTimestamp = block.timestamp;
        emit ReceiveReward(msg.sender,nftId, weekIndex, nftAddress,rewardAmount,block.timestamp);
    }

    // 查询分红记录
    function queryReward(address user,uint256 year) public view returns(RewardOrder[] memory){
        uint256[] memory rewardWeekIndexes =  userRewardByYearOrders[user][year];
        RewardOrder[] memory rewards = new RewardOrder[](rewardWeekIndexes.length);
        for (uint256 i = 0;i < rewardWeekIndexes.length;i++){
            rewards[i] = userRewardByWeekOrders[user][rewardWeekIndexes[i]];
        }
        return rewards;
    }

    
    


}