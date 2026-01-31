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
contract JWTradeMinner is  Initializable,
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
            address _jwToken,
            address _usdtAddress,
            address _swapRouterAddress,
            address _manageContractAddress,
            address _recommandContractAddress,
            uint256[] memory _tradeVolumePerDay,
            uint256[] memory _produceTokenVolumePerDay
        
        ) public initializer {
            __AccessControlEnumerable_init();
            __ReentrancyGuard_init();
            __UUPSUpgradeable_init();
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MANAGE_ROLE, msg.sender);
            _grantRole(OPERATE_ROLE, operator);
            jwToken = _jwToken;
            usdtAddress = _usdtAddress;
            swapRouterAddress = _swapRouterAddress;
            manageContractAddress = _manageContractAddress;
            recommandContractAddress = _recommandContractAddress;
            tradeVolumePerDay = _tradeVolumePerDay;
            produceTokenVolumePerDay = _produceTokenVolumePerDay;
            recommandLevel = 8;
            staticPercent = 350;
            dynamaticPercent = 650;
        }


    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    /////////////////////////////////////////////////////////////*/
    address jwToken;
    address usdtAddress;
    address manageContractAddress;
    address recommandContractAddress;
    address swapRouterAddress;
    // Sort by size from largest to smallest
    uint256[] tradeVolumePerDay;
    uint256[] produceTokenVolumePerDay;
    mapping(uint256 => uint256) produceTokenPerDay;
    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public constant SECONDS_PER_YEAR = 365 days;
    

    // 交易量
    // 个人日交易额
    mapping(address => mapping(uint256 => uint256)) userTradePerDay;
    // 个人总交易额
    mapping(address => uint256) userTradeTotal;
    // 个人日推荐交易量
    mapping(address => mapping(uint256 => uint256)) userReferalChainTradePerDay;
    // 平台日交易量
    mapping(uint256 => uint256) platformTradePerDay;
    // 平台总交易量
    uint256 platformTradeTotal;
    // 平台日推荐交易量
    mapping(uint256 => uint256) platformReferalChainTradePerDay;

    // 用户交易记录
    struct Swap {
        uint256 orderId;
        uint8 swapType;
        address userAddr;
        uint256 amountIn;
        uint256 amountOut;
        uint256 timestamp;
    }
    mapping(uint256 => Swap) orders;
    mapping(address => mapping(uint256 => uint256[])) userOrderIdsPerDay;
    uint256 orderId;

    struct UserInfo {
        uint256 staticRewardBalance;      // 奖励
        uint256 dynRewardBalance;      // 奖励
        uint256 lastCalRewardTime;  // 上次计算奖励时间
        uint256 fristOrderTime;  // 首次下单时间
        uint256 staticRewardReceived;  // 已领取奖励
        uint256 dynRewardReceived;  // 已领取奖励
    }
    mapping(address => UserInfo) public users;
    uint256 recommandLevel;
    uint256 staticPercent;
    uint256 dynamaticPercent;
    uint256 public constant DENOMINATOR = 1000;
    uint256 rewardReceivedOrderId;
    uint256 rewardGenerateId;
    struct RewardReceivedRecord{
        uint256 rewardReceivedOrderId;
        uint8 productionType;
        uint256 amount;
        uint256 timestamp;
    }
    mapping(uint256 => RewardReceivedRecord) public rewardReceivedRecords;
    mapping(address => mapping(uint256 => uint256[])) public userRewardReceivedRecords;

    struct RewardGenerateRecord{
        uint256 rewardGenerateId;
        uint256 tradeAmount;
        uint256 recommandAmount;
        uint256 staticProductionAmount;
        uint256 dynProductionAmount;
        uint256 timestamp;
    }
    mapping(uint256 => RewardGenerateRecord) public rewardGenerateRecords;
    mapping(address => mapping(uint256 => uint256[])) public userRewardGenerateRecords;
    

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event BuyJW(address user,uint256 amountIn,uint256 amountOut,uint256 dayIndex,uint256 currentOrderId,
    uint256 userTradeTotalVol,uint256 userTradePerDayVol,uint256 platformTradeTotalVol,uint256 platformTradePerDayVol,uint256 createTime);
    event SellJW(address user,uint256 amountIn,uint256 amountOut,uint256 dayIndex,uint256 currentOrderId,
    uint256 userTradeTotalVol,uint256 userTradePerDayVol,uint256 platformTradeTotalVol,uint256 platformTradePerDayVol,uint256 createTime);
    event  CalcaulateReward(address user,uint256 staticRewardBalance,uint256 dynRewardBalance,uint256 lastCalRewardTime,uint256 fristOrderTime,uint256 staticRewardReceived,uint256 dynRewardReceived,uint256 timestamp);
    event ReceiveProduction(address user,address token,uint8 productionType,uint256 amount,uint256 timestamp);
    
    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function produceTokens(uint256 dayIndex) internal {
        if (produceTokenPerDay[dayIndex] == 0){
            uint256 platformTrade = getPlatformTradePerDay(dayIndex);
            if (platformTrade !=0){
                (bool hasReslut,uint256 result) = getTradeVolumePerDayIndex(platformTrade);
                if (hasReslut){
                    uint256 produceAmount = produceTokenVolumePerDay[result];
                    // mint token
                    IJWErc20(jwToken).mint(address(this),produceAmount);
                    produceTokenPerDay[dayIndex] = produceAmount;
                }
            }
        }
    }



    // 买jw
    function buyJW() public payable nonReentrant {
        uint256 createTime = block.timestamp;
        uint256 dayIndex = getDayIndex(createTime);
        require(msg.value > 0,"msg.value should >0");
        // validate recommand
        (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
        require(referrer != address(0),"user is not recommanded");
        uint256 jwReceived = pijsBuyJw(msg.value);
        SafeERC20.safeTransferFrom(IERC20(jwToken), address(this) ,msg.sender, jwReceived);

        // 更新订单
        uint256 currentOrderId = orderId;
        Swap memory order = Swap({
            orderId : currentOrderId,
            swapType: 1,
            userAddr:msg.sender,
            amountIn:msg.value,
            amountOut:jwReceived,
            timestamp:createTime
        });
        orders[currentOrderId] = order;
        userOrderIdsPerDay[msg.sender][dayIndex].push(currentOrderId);

        // 更新交易量
        // 平台交易量
        uint256 usdtValue = getJW2USDT(jwReceived);
        platformTradeTotal = platformTradeTotal + usdtValue;
        platformTradePerDay[dayIndex] = platformTradePerDay[dayIndex] + usdtValue;
        // 个人交易量
        userTradeTotal[msg.sender] = userTradeTotal[msg.sender] + usdtValue;
        uint256 vollume = getJWTradeVollumePerDay(msg.sender,dayIndex);
        userTradePerDay[msg.sender][dayIndex] = getJW2USDT(vollume);
        
        updateRecommandTradePerday(dayIndex,msg.value,msg.sender);

        if (users[msg.sender].fristOrderTime == 0){
            UserInfo memory user = UserInfo({
                staticRewardBalance : 0,
                dynRewardBalance : 0,
                lastCalRewardTime : 0,
                fristOrderTime : createTime,
                staticRewardReceived : 0,
                dynRewardReceived:0
            });
            users[msg.sender] = user;
        }

        emit BuyJW(msg.sender,msg.value,jwReceived,dayIndex,currentOrderId,userTradeTotal[msg.sender],userTradePerDay[msg.sender][dayIndex],platformTradeTotal,platformTradePerDay[dayIndex],createTime);
    }
    // 计算个人每天的交易量
    function getJWTradeVollumePerDay(address user,uint256 dayIndex) public view returns(uint256){
        uint256[] memory orderIds = userOrderIdsPerDay[user][dayIndex];
        uint256 sellAmount;
        uint256 buyAmount;
        for (uint256 i = 0;i < orderIds.length;i++){
            if (orders[orderIds[i]].swapType == 1){
                buyAmount = buyAmount + orders[orderIds[i]].amountOut;
            } else {
                sellAmount = sellAmount + orders[orderIds[i]].amountIn;
            }
        }
        uint256 vollume;
        if (sellAmount == 0 || buyAmount == 0){
            vollume = 0;
        } else {
            if (sellAmount <= buyAmount){
                vollume = sellAmount * 2;
            } else {
                vollume = buyAmount * 2;
            }
        }
        return vollume;
    }

    function updateRecommandTradePerday(uint256 dayIndex,uint256 amount,address user) internal {
        // 推荐日交易量
        (,,,address[] memory referralChain) = IRecommendation(recommandContractAddress).getUserInfo(user);
        uint256 level;
        if (referralChain.length > recommandLevel){
            level = recommandLevel;
        } else {
            level = referralChain.length;
        }
        for (uint256 i = 0;i < level ;i++){
            userReferalChainTradePerDay[referralChain[i]][dayIndex] = userReferalChainTradePerDay[referralChain[i]][dayIndex]+ (
                amount / (2 ** i)
            );
            platformReferalChainTradePerDay[dayIndex] =  platformReferalChainTradePerDay[dayIndex] + (
                amount / (2 ** i)
            );
        }
        
    }

    



    // 卖jw
    function sellJW(address jwAddress,uint256 amount) public  nonReentrant {
        uint256 createTime = block.timestamp;
        uint256 dayIndex = getDayIndex(createTime);
        // validate recommand
        (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
        require(referrer != address(0),"user is not recommanded");
        require(amount > 0,"amount should >0");
        require(jwAddress == jwToken,"Invalid jw token");
        uint256 ethReceived = jwBuyPIJS(amount);
        (bool ok, ) = msg.sender.call{value: ethReceived}("");
        require(ok, "msg sender received pijs transfer failed");

        // 更新订单
        uint256 currentOrderId = orderId;
        Swap memory order = Swap({
            orderId : currentOrderId,
            swapType: 2,
            userAddr:msg.sender,
            amountIn:amount,
            amountOut:ethReceived,
            timestamp:createTime
        });
        orders[currentOrderId] = order;
        userOrderIdsPerDay[msg.sender][dayIndex].push(currentOrderId);

        // 更新交易量
        // 平台交易量
        uint256 usdtValue = getPIJS2USDT(ethReceived);
        platformTradeTotal = platformTradeTotal + usdtValue;
        platformTradePerDay[dayIndex] = platformTradePerDay[dayIndex] + usdtValue;
        // 个人交易量
        userTradeTotal[msg.sender] = userTradeTotal[msg.sender] + usdtValue;
        uint256 vollume = getJWTradeVollumePerDay(msg.sender,dayIndex);
        userTradePerDay[msg.sender][dayIndex] = getPIJS2USDT(vollume);

        updateRecommandTradePerday(dayIndex,amount,msg.sender);
        if (users[msg.sender].fristOrderTime == 0){
            UserInfo memory user = UserInfo({
                staticRewardBalance : 0,
                dynRewardBalance: 0,
                lastCalRewardTime : 0,
                fristOrderTime : createTime,
                staticRewardReceived : 0,
                dynRewardReceived: 0
            });
            users[msg.sender] = user;
        }

        emit SellJW(msg.sender,amount,ethReceived,dayIndex,currentOrderId,userTradeTotal[msg.sender],userTradePerDay[msg.sender][dayIndex],platformTradeTotal,platformTradePerDay[dayIndex],createTime);
    }

    function jwBuyPIJS(uint256 buyPIJSAmount) internal returns(uint256) {
        // 1. 先从用户拉 USDT
        SafeERC20.safeTransferFrom(IERC20(jwToken), msg.sender, address(this), buyPIJSAmount);
        // 2. 再授权 Router
        SafeERC20.safeApprove(IERC20(jwToken), swapRouterAddress, 0);
        SafeERC20.safeApprove(IERC20(jwToken),swapRouterAddress, buyPIJSAmount);
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // 2. USDT -> WETH
        address[] memory path1 = new address[](2);
        path1[0] = jwToken;
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
    function pijsBuyJw(uint256 pijsAmount) internal returns(uint256){
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
        // WETH -> JW
        uint256 beforeJWAmount = IERC20(jwToken).balanceOf(address(this));
        address[] memory path2 = new address[](2);
        path2[0] = swapRouter.WETH();
        path2[1] = jwToken;
        swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: pijsAmount}(
            0,
            path2,
            address(this),
            block.timestamp + 300
        );
        uint256 afterJWAmount = IERC20(jwToken).balanceOf(address(this));
        uint256 jwReceived = afterJWAmount - beforeJWAmount;
        return jwReceived;
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

    // 计算个人奖励
    function calcaulateReward() public payable nonReentrant {
        // validate recommand
        (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
        require(referrer != address(0),"user is not recommanded");
        uint256 currentTime = block.timestamp;
        // 判断用户有多少天未计算奖励
        UserInfo memory user = users[msg.sender];
        require(user.fristOrderTime != 0,"user have not swaped");
        uint256 todayIndex = getDayIndex(currentTime);
        uint256 calculateTime;
        if (user.lastCalRewardTime == 0){
            calculateTime = user.fristOrderTime;
        } else {
            calculateTime = user.lastCalRewardTime;
        }
        uint256 calculateTimeDayIndex = getDayIndex(calculateTime);
        require(calculateTimeDayIndex < todayIndex,"No reward generated");
        uint256 calculateDays = todayIndex - calculateTimeDayIndex;

        for (uint256 i = 0;i < calculateDays;i++){
            // 计算日的总量
            uint256 currentDayTotal = platformTradePerDay[calculateTimeDayIndex + i];
            if (currentDayTotal != 0){
                // 计算日用户的质押总量
                uint256 currentDayUserTotal = userTradePerDay[msg.sender][calculateTimeDayIndex + i];
                if (currentDayUserTotal != 0){
                    uint256 currentDayProduce = getDayProduction(calculateTimeDayIndex + i);
                    if (currentDayProduce != 0) {
                        uint256 staticReward =  currentDayUserTotal * (currentDayProduce * staticPercent / DENOMINATOR)/currentDayTotal;
                        uint256 dynamaticReward = (currentDayUserTotal + userReferalChainTradePerDay[msg.sender][calculateTimeDayIndex + i])
                        * (currentDayProduce * dynamaticPercent / DENOMINATOR)
                        / (currentDayTotal + platformReferalChainTradePerDay[calculateTimeDayIndex + i]);
                        RewardGenerateRecord memory rgr = RewardGenerateRecord({
                            rewardGenerateId:rewardGenerateId,
                            tradeAmount:currentDayUserTotal,
                            recommandAmount:userReferalChainTradePerDay[msg.sender][calculateTimeDayIndex + i],
                            staticProductionAmount:staticReward,
                            dynProductionAmount:dynamaticReward,
                            timestamp: currentTime
                        });
                        rewardGenerateRecords[rewardGenerateId] = rgr;
                        userRewardGenerateRecords[msg.sender][getYearIndex(currentTime)].push(rewardGenerateId);
                        users[msg.sender].staticRewardBalance = users[msg.sender].staticRewardBalance  + staticReward;
                        users[msg.sender].dynRewardBalance = users[msg.sender].dynRewardBalance  + dynamaticReward;
                        users[msg.sender].lastCalRewardTime = block.timestamp;

                        rewardGenerateId = rewardGenerateId + 1;
                    }
                }
            }
        }
        emit CalcaulateReward(msg.sender,users[msg.sender].staticRewardBalance,users[msg.sender].dynRewardBalance,users[msg.sender].lastCalRewardTime,users[msg.sender].fristOrderTime,users[msg.sender].staticRewardReceived,users[msg.sender].dynRewardReceived,block.timestamp);
    }
    function getDayProduction(uint256 dayIndex) internal view returns(uint256){
        uint256 currentDayTotal = platformTradePerDay[dayIndex];
        uint256 dayProduction;
        for (uint256 i = 0;i < tradeVolumePerDay.length;i++){
            if (currentDayTotal >= tradeVolumePerDay[i]){
                dayProduction = produceTokenVolumePerDay[i];
                break;
            }
        }
        return dayProduction;
    }

    // 领取查出
    function receiveProduction(address token,uint256 amount,uint8 productionType) public nonReentrant{
        // validate recommand
        (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
        require(token == jwToken,"Invalid token address");
        require(amount > 0,"amount should > 0");
        require(referrer != address(0),"user is not recommanded");
        require(productionType == 0 || productionType == 1,"productionType should be 0 or 1");

        if (productionType == 0){
            require(users[msg.sender].staticRewardBalance > 0,"no static production");
            require(users[msg.sender].staticRewardBalance >= amount,"not enough static production");
            SafeERC20.safeTransferFrom(IERC20(token), address(this),msg.sender, amount);
            users[msg.sender].staticRewardBalance = users[msg.sender].staticRewardBalance - amount;
            users[msg.sender].staticRewardReceived = users[msg.sender].staticRewardReceived + amount;

        } else {
            require(users[msg.sender].dynRewardBalance > 0,"no dyn production");
            require(users[msg.sender].dynRewardBalance >= amount,"not enough dyn production");
            SafeERC20.safeTransferFrom(IERC20(token), address(this),msg.sender, amount);
            users[msg.sender].dynRewardBalance = users[msg.sender].dynRewardBalance - amount;
            users[msg.sender].dynRewardReceived = users[msg.sender].dynRewardReceived + amount;

        }
        rewardReceivedRecords[rewardReceivedOrderId].rewardReceivedOrderId = rewardReceivedOrderId;
        rewardReceivedRecords[rewardReceivedOrderId].productionType = productionType;
        rewardReceivedRecords[rewardReceivedOrderId].amount = amount;
        rewardReceivedRecords[rewardReceivedOrderId].timestamp = block.timestamp;
        userRewardReceivedRecords[msg.sender][getYearIndex(block.timestamp)].push(rewardReceivedOrderId);

        rewardReceivedOrderId = rewardReceivedOrderId + 1;
        emit ReceiveProduction(msg.sender,token,productionType,amount,block.timestamp);
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

    function getTradeVolumePerDayIndex(uint256 platformTrade) internal view returns(bool,uint256) {
        bool hasResult;
        uint256 result;
        for (uint256 i = 0;i < tradeVolumePerDay.length;i++){
            if (tradeVolumePerDay[i] <= platformTrade){
                hasResult = true;
                result = i;
                break;
            }
        }
        return (hasResult,result);
    }

    function getUserTradeTotal(address user) external view returns(uint256) {
        return userTradeTotal[user];
    }
    function getUserTradePerDay(address user,uint256 dayIndex) external view returns(uint256) {
        return userTradePerDay[user][dayIndex];
    }
    function getPlatformTradeTotal() external view returns(uint256){
        return platformTradeTotal;
    }
    function getPlatformTradePerDay(uint256 dayIndex) public  view returns(uint256) {
        return platformTradePerDay[dayIndex];
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

    function getOrder(uint256 _orderId) external view returns(Swap memory) {
        return orders[_orderId];
    }
    function getUserOrderIdsPerday(address user,uint256 dayIndex) external view returns (uint256[] memory){
        return userOrderIdsPerDay[user][dayIndex];
    }

    // 查询奖励记录
    function queryRewardGenerateRecords(uint256 year,address user) public view returns(RewardGenerateRecord[] memory){
        uint256[] memory recordIds = userRewardReceivedRecords[user][year];
        RewardGenerateRecord[] memory records = new RewardGenerateRecord[](recordIds.length);
        for (uint256 i = 0;i < recordIds.length;i++){
            records[i] = rewardGenerateRecords[recordIds[i]];
        }
        return records;
    }

    // 查询奖励领取记录
    function queryRewardReceivedRecord(uint256 year,address user) public view returns(RewardReceivedRecord[] memory){
        uint256[] memory recordIds = userRewardGenerateRecords[user][year];
        RewardReceivedRecord[] memory records = new RewardReceivedRecord[](recordIds.length);
        for (uint256 i = 0;i < recordIds.length;i++){
            records[i] = rewardReceivedRecords[recordIds[i]];
        }
        return records;
    }

    function setParams(
        address _jwToken,
        address _usdtAddress,
        address _swapRouterAddress,
        address _manageContractAddress,
        address _recommandContractAddress,
        uint256[] memory _tradeVolumePerDay,
        uint256[] memory _produceTokenVolumePerDay,
        uint256 _recommandLevel,
        uint256 _staticPercent,
        uint256 _dynamaticPercent) external onlyRole(MANAGE_ROLE){
           require(_jwToken != address(0),"0 address"); 
           require(_usdtAddress != address(0),"0 address"); 
           require(_swapRouterAddress != address(0),"0 address"); 
           require(_manageContractAddress != address(0),"0 address"); 
           jwToken = _jwToken;
           usdtAddress = _usdtAddress;
           swapRouterAddress = _swapRouterAddress;
           manageContractAddress = _manageContractAddress;
           recommandContractAddress = _recommandContractAddress;
           tradeVolumePerDay = _tradeVolumePerDay;
           produceTokenVolumePerDay = _produceTokenVolumePerDay;
           recommandLevel = _recommandLevel;
           staticPercent = _staticPercent;
           dynamaticPercent = _dynamaticPercent;
    }



    receive() external payable {}
    
    





}