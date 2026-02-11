// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../interface/INFTSell.sol";
contract InteractionAirDrop is  Initializable,
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
            address _jwToken,
            address _receiver,
            address _developer,
            uint256 _developerPersentage,
            address _recommandContractAddress,
            address _swapRouterAddress,
            address _swapOrangeRouterAddress,
            uint256 _wearRate
        ) public initializer {
            __AccessControlEnumerable_init();
            __ReentrancyGuard_init();
            __UUPSUpgradeable_init();
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MANAGE_ROLE, msg.sender);

            usdtAddress = _usdtAddress;
            receiver = _receiver;
            developer = _developer;
            developerPersentage = _developerPersentage;
            recommandContractAddress = _recommandContractAddress;
            swapRouterAddress = _swapRouterAddress;
            swapOrangeRouterAddress = _swapOrangeRouterAddress;
            jwToken = _jwToken;
            wearRate = _wearRate;

            Product memory p1 = Product({
                productId : 1,
                usdtValue: 1 ether,
                jwAmountPerCopy:100 ether,
                buyLimit : 5,
                limit:50000,
                currentInteractionTimes:0,
                realsePerioid: 24,
                enabled : true,
                startTime: 0
            });
            Product memory p2 = Product({
                productId : 2,
                usdtValue: 1 ether,
                jwAmountPerCopy:500 ether,
                buyLimit : 5,
                limit:50000,
                currentInteractionTimes:0,
                realsePerioid: 24,
                enabled : false,
                startTime: 0
            });
            Product memory p3 = Product({
                productId : 3,
                usdtValue: 1 ether,
                jwAmountPerCopy:500 ether,
                buyLimit : 5,
                limit:50000,
                currentInteractionTimes:0,
                realsePerioid: 24,
                enabled : false,
                startTime: 0
            });
            products[1] = p1;
            products[2] = p2;
            products[3] = p3;

        }

        /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
        /////////////////////////////////////////////////////////////*/
        struct Order {
            uint256 orderId;
            address userAddr;
            uint256 pijsAmount;
            uint8 productId;
            uint256 jwAmount;
            uint256 createTime;
            uint256 purchaseSameQuantity;
            uint256 purchaseSameQuantityTime;
            bool isReceived;
            uint256 receivedTime;
        }
        struct Product{
            uint8 productId;
            uint256 usdtValue;
            uint256 jwAmountPerCopy;
            uint buyLimit;
            uint256 limit;
            uint256 currentInteractionTimes;
            uint256 realsePerioid;
            bool enabled;
            uint256 startTime;
        }
        address jwToken;
        address usdtAddress;
        address recommandContractAddress;
        address swapRouterAddress;
        address swapOrangeRouterAddress;
        address receiver;
        address developer;
        uint256 public constant SECONDS_PER_HOUR = 60 * 60;
        uint256 orderId;
        uint256 public wearRate;
        uint256 public constant DENOMINATOR = 1000;
        uint256 developerPersentage;
        mapping(uint8 => Product) products;
        mapping(uint256 => Order) orders;
        mapping(address => mapping(uint8 => uint256[])) userOrders;

        struct UserInfo {
            address user;
            uint256 myIntegration; 
            mapping(address => uint256) userDirectRecomandIntegration;
            mapping(address => uint256) userIndirectRecomandIntegration;
            
            
            mapping(uint256 => uint256) buyJWAmount;
            mapping(uint256 => uint256) realseBuyJWAmount;
            mapping(uint256 => uint256) buyTimestamp;
           

            mapping(uint256 => uint256)  airdropJwAmount;
            mapping(uint256 => uint256)  airdropJwReceivedAmount;
            mapping(uint256 => uint256)  airdropJwTime;
            mapping(uint256 => uint256)  receivedTimestamp;

        }
        mapping(address => UserInfo) userInfos;

        
        
        /*//////////////////////////////////////////////////////////////
                            EVENTS
        //////////////////////////////////////////////////////////////*/
        event JoinAirDrop(address userAddr,uint8 productId,uint256 amount,address receiver,uint256 currentOrderId,address referrer,address indriectReferrer,uint256 driectReferrerIntegrationInc,uint256 inDriectReferrerIntegrationInc,uint256 timestamp);
        event CheckOrder(address userAddr,uint256 orderId,uint256 jwAmount,uint256 timestamp);
        event BuyJW(address userAddr,uint256 pijsAmount,uint256 jwReceived,uint256 timestamp);

        /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
        //////////////////////////////////////////////////////////////*/
        function joinAirDrop(uint8 productId) public payable nonReentrant {
            require(productId != 0,"Invaild product");
            require(products[productId].enabled == true,"product not enabled");
            (address referrer,,,address[] memory referralChain) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
            require(referrer != address(0),"user is not recommanded");
            require(msg.value>0,"value shoud >0");
            // 判断jw和pijs价值的usdt价值是否
            uint256 buyPIJSAmount2usd = getPIJS2USDT(msg.value);
            uint256 usdtValue = products[productId].usdtValue;
            require(buyPIJSAmount2usd >= usdtValue * (DENOMINATOR - wearRate)/DENOMINATOR ,"the value of  pijs can not reached usdtValue");
            // limit
            require(userOrders[msg.sender][productId].length < products[productId].buyLimit,"exceeded the buy limit");
            require(products[productId].currentInteractionTimes < products[productId].limit,"exceeded the product limit");

            uint256 developerAmount = msg.value * developerPersentage / DENOMINATOR;
            uint256 receiverAmount = msg.value - developerAmount;
            // receiver
            (bool ok1, ) = receiver.call{value: receiverAmount }("");
            require(ok1, "receiver received pijs transfer failed");
            
            //10% --> developer address
            (bool ok2, ) = developer.call{value: developerAmount }("");
            require(ok2, "developer received pijs transfer failed");

            // UPDATE to integation
            uint256 driectReferrerIntegrationInc;
            uint256 inDriectReferrerIntegrationInc;
            if(userInfos[referrer].user == address(0)){
                userInfos[referrer].user = referrer;
            } 
            if(userInfos[referrer].userDirectRecomandIntegration[msg.sender] == 0){
                // 1 积分
                driectReferrerIntegrationInc = 1 ether;
                userInfos[referrer].userDirectRecomandIntegration[msg.sender] = driectReferrerIntegrationInc;
                userInfos[referrer].myIntegration =  userInfos[referrer].myIntegration + driectReferrerIntegrationInc;
            }
            address indriectReferrer;
            if (referralChain.length > 1){
                indriectReferrer = referralChain[1];
                if(userInfos[indriectReferrer].user == address(0)){
                    userInfos[indriectReferrer].user = indriectReferrer;
                } 
                if (indriectReferrer!= address(0)){
                    if (userInfos[indriectReferrer].userIndirectRecomandIntegration[msg.sender] ==0){
                        // 0.5 积分
                        inDriectReferrerIntegrationInc = 0.5 ether;
                        userInfos[indriectReferrer].userIndirectRecomandIntegration[msg.sender] = inDriectReferrerIntegrationInc;
                        userInfos[indriectReferrer].myIntegration = userInfos[indriectReferrer].myIntegration + inDriectReferrerIntegrationInc;
                    }
                }
            }
            uint256 currentOrderId = orderId;
            require(orders[currentOrderId].userAddr == address(0),"order existed");
            Order memory order = Order({
                orderId:currentOrderId,
                userAddr : msg.sender,
                pijsAmount : msg.value,
                productId:productId,
                jwAmount: products[productId].jwAmountPerCopy,
                createTime:block.timestamp,
                purchaseSameQuantity:0,
                purchaseSameQuantityTime:0,
                isReceived:false,
                receivedTime:0
            });
            orders[currentOrderId] = order;
            userOrders[msg.sender][productId].push(currentOrderId);
            products[productId].currentInteractionTimes = products[productId].currentInteractionTimes +1;
            orderId = orderId + 1;

            userInfos[msg.sender].airdropJwAmount[productId] = userInfos[msg.sender].airdropJwAmount[productId] + products[productId].jwAmountPerCopy;
            userInfos[msg.sender].airdropJwTime[productId] = block.timestamp;

            emit JoinAirDrop(msg.sender,productId,msg.value,receiver,currentOrderId,referrer,indriectReferrer,driectReferrerIntegrationInc,inDriectReferrerIntegrationInc,block.timestamp);
        }

        // 购买同等数量的JW
        function buyJW(uint256 productId,uint256 _orderId) public payable nonReentrant {
            
            require(orders[_orderId].userAddr != address(0),"order is not exist");
            require(orders[_orderId].userAddr == msg.sender,"order is not exist");
            require(msg.value > 0,"zero pijs sended");
            // need buy amount
            uint256 jwAmount = orders[_orderId].jwAmount;
            uint256 needPijs = getJW2PIJS(jwAmount);
            require(msg.value >= needPijs,"pijs is not enough sended");
            IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
            // 检查交易对是否存在
            address pair = IUniswapV2Factory(swapRouter.factory()).getPair(
                swapRouter.WETH(), 
                jwToken
            );
            require(pair != address(0), "No liquidity pool");
            
            // 检查流动性
            (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
            require(reserve0 > 0 && reserve1 > 0, "Insufficient liquidity");
            // WETH -> JW
            uint256 beforeJWAmount = IERC20(jwToken).balanceOf(address(this));
            address[] memory path2 = new address[](2);
            path2[0] = swapRouter.WETH();
            path2[1] = jwToken;
            swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                path2,
                address(this),
                block.timestamp + 300
            );
            uint256 afterJWAmount = IERC20(jwToken).balanceOf(address(this));
            uint256 jwReceived = afterJWAmount - beforeJWAmount;
            SafeERC20.safeTransfer(IERC20(jwToken), msg.sender, jwReceived);

            userInfos[msg.sender].buyJWAmount[productId] = userInfos[msg.sender].buyJWAmount[productId] + jwReceived;
            userInfos[msg.sender].buyTimestamp[productId] = block.timestamp;

            orders[_orderId].purchaseSameQuantity = jwReceived;
            orders[_orderId].purchaseSameQuantityTime = block.timestamp;

            emit BuyJW(msg.sender,msg.value,jwReceived,block.timestamp);

        }

        function getPIJS2JW(uint256 amount) public view returns(uint256) {
            IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
            // pijs-> usdt
            address[] memory path2 = new address[](2);
            path2[0] = swapRouter.WETH();
            path2[1] = jwToken;

            uint[] memory amounts2 = swapRouter.getAmountsOut(amount, path2);
            uint256 jwAmount = amounts2[1];
            require(jwAmount > 0, "pijs->jw quote failed");
            
            return jwAmount;
        }
        
        function getJW2PIJS(uint256 amount) public view returns(uint256) {
            IUniswapV2Router02 swapRouter = IUniswapV2Router02(swapRouterAddress);
            // pijs-> usdt
            address[] memory path2 = new address[](2);
            path2[0] = jwToken;
            path2[1] = swapRouter.WETH();

            uint[] memory amounts2 = swapRouter.getAmountsOut(amount, path2);
            uint256 pijsAmount = amounts2[1];
            require(pijsAmount > 0, "pijs->jw quote failed");
            
            return pijsAmount;
        }





        // 领取jw
        function checkJW(uint256 _orderId,uint8 productId) public {
            // is your's order
            Order memory order = orders[_orderId];
            require(order.userAddr != address(0),"the order is not exist");
            require(msg.sender == order.userAddr,"the owner of the order is not you");
            require(productId == order.productId,"the product is not correct");
            require(order.isReceived == false,"the order is already received");
            require(order.createTime <= block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR,"the order is not yet expired");
            require(userInfos[msg.sender].buyJWAmount[productId] >=  order.jwAmount,"need buy the same amount of jw");
            SafeERC20.safeTransfer(IERC20(jwToken), msg.sender, order.jwAmount);
            
            userInfos[msg.sender].realseBuyJWAmount[productId] = userInfos[msg.sender].realseBuyJWAmount[productId] + order.jwAmount;

            userInfos[msg.sender].airdropJwReceivedAmount[productId] = userInfos[msg.sender].airdropJwReceivedAmount[productId] + order.jwAmount;
            userInfos[msg.sender].receivedTimestamp[productId]  = block.timestamp;

            orders[_orderId].isReceived = true;
            orders[_orderId].receivedTime = block.timestamp;

            emit CheckOrder(msg.sender,order.orderId,order.jwAmount,block.timestamp);
        }


        /*//////////////////////////////////////////////////////////////
                            FUNCTIONS   setter  getter query
        //////////////////////////////////////////////////////////////*/
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

        // 查询待领取的  (待释放)
        function checkPendingCollectionOrder(address user,uint8 productId) public view returns(Order[] memory ,uint256){
            uint256[] memory orderIds = userOrders[user][productId];
            uint256 amount;
            uint256 length;
            for (uint256 i = 0;i < orderIds.length;i++){
                if (orders[orderIds[i]].purchaseSameQuantityTime != 0  && orders[orderIds[i]].purchaseSameQuantityTime <= block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                    length++;
                }
            }
            Order[] memory rorders = new Order[](length);
            uint256 index;
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].purchaseSameQuantityTime != 0 &&  orders[orderIds[i]].purchaseSameQuantityTime <= block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                        rorders[index]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            createTime: orders[orderIds[i]].createTime,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime,
                            purchaseSameQuantity:orders[orderIds[i]].purchaseSameQuantity,
                            purchaseSameQuantityTime:orders[orderIds[i]].purchaseSameQuantityTime
                        });
                        amount = amount + orders[orderIds[i]].jwAmount;
                        index = index + 1;
                    }
                }
            }
            return (rorders,amount);
        }
        // 查询已领取
        function checkingReceivedOrder (address user,uint8 productId) public view returns(Order[] memory,uint256){
            uint256[] memory orderIds = userOrders[user][productId];
            uint256 length;
            uint256 amount;
            for (uint256 i = 0;i < orderIds.length;i++){
                 if (orders[orderIds[i]].isReceived == true){
                    length++;
                }
            }
            Order[] memory rorders = new Order[](length);
            uint256 index;
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].isReceived == true){
                        rorders[index]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            createTime: orders[orderIds[i]].createTime,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime,
                            purchaseSameQuantity:orders[orderIds[i]].purchaseSameQuantity,
                            purchaseSameQuantityTime:orders[orderIds[i]].purchaseSameQuantityTime
                        });
                        amount = amount + orders[orderIds[i]].jwAmount;
                        index = index+1;
                    }
                }
            }
             return (rorders,amount);
        }



        // 查询未到期（释放中）
        function checkingNotYetExpired(address user,uint8 productId) public view returns(Order[] memory,uint256 ){
            uint256[] memory orderIds = userOrders[user][productId];
            uint256 length;
            uint256 amount;
            for (uint256 i = 0;i < orderIds.length;i++){
                if (orders[orderIds[i]].purchaseSameQuantityTime != 0  && orders[orderIds[i]].purchaseSameQuantityTime > block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                    length++;
                }
            }
            Order[] memory rorders = new Order[](length);
            uint256 index;
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].purchaseSameQuantityTime != 0  && orders[orderIds[i]].purchaseSameQuantityTime > block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                        rorders[index]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            createTime: orders[orderIds[i]].createTime,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime,
                            purchaseSameQuantity:orders[orderIds[i]].purchaseSameQuantity,
                            purchaseSameQuantityTime:orders[orderIds[i]].purchaseSameQuantityTime
                        });
                        amount = amount + orders[orderIds[i]].jwAmount;
                        index = index + 1;
                    }
                }
            }
           return (rorders,amount);
        }

        // 查询用户全部
        function checkingAllOrders (address user,uint8 productId) public view returns(Order[] memory){
            uint256[] memory orderIds = userOrders[user][productId];
            Order[] memory rorders = new Order[](orderIds.length);
            if (orderIds.length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                        rorders[i]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            createTime: orders[orderIds[i]].createTime,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime,
                            purchaseSameQuantity:orders[orderIds[i]].purchaseSameQuantity,
                            purchaseSameQuantityTime:orders[orderIds[i]].purchaseSameQuantityTime
                        });
                }
            }
            return rorders;
        }

        // 获取交互次数
        function getInteractionTimes(address user,uint8 productId) public view returns(uint256,uint256,uint256,uint256){
            return (
                products[productId].limit,
                products[productId].currentInteractionTimes,
                products[productId].limit - products[productId].currentInteractionTimes,
                products[productId].buyLimit - userOrders[user][productId].length
            );
        }

        function setProduct(
            uint8 _productId,
            uint256 _usdtValue,
            uint _buyLimit,
            uint256 _limit,
            uint256 _realsePerioid,
            bool _enabled,
            uint256 _startTime) external onlyRole(MANAGE_ROLE) {

                products[_productId].productId = _productId;
                products[_productId].usdtValue = _usdtValue;
                products[_productId].buyLimit = _buyLimit;
                products[_productId].limit = _limit;
                products[_productId].realsePerioid = _realsePerioid;
                products[_productId].enabled = _enabled;
                products[_productId].startTime = _startTime;
        }
        function getProducts() external view returns(Product memory,Product memory,Product memory){
            return (products[1],products[2],products[3]);
        }

        function setWearRate(uint256 _wearRate)external onlyRole(MANAGE_ROLE) {
            wearRate = _wearRate;
        }

        // 用户积分信息查询
        function getUserIntegration(address user) public view returns(uint256){
            return userInfos[user].myIntegration;
        }
        struct RecomandCol{
            address referral;
            bool hasOrder;
            uint256 grade;
        }
        function getUserInfo(address user) public view returns(uint256,uint256,uint256,RecomandCol[] memory) {
            (,,address[] memory referrals,) = IRecommendation(recommandContractAddress).getUserInfo(user);
            uint256 myIntegration = userInfos[user].myIntegration;
            uint256 referralsCount = referrals.length;
            uint256 interactCount;
            RecomandCol[] memory rcols = new RecomandCol[](referralsCount);

            for (uint256 i = 0; i < referrals.length; i++){
                bool hasOrder;
                if (userOrders[referrals[i]][1].length >0){
                    hasOrder = true;
                }
                if (userOrders[referrals[i]][2].length >0){
                    hasOrder = true;
                }
                if (userOrders[referrals[i]][3].length >0){
                    hasOrder = true;
                }
                if (hasOrder){
                    interactCount = interactCount + 1;
                }
                rcols[i] = RecomandCol({
                    referral : referrals[i],
                    hasOrder : hasOrder,
                    grade : 0
                });
            }
            return (referralsCount,interactCount,myIntegration,rcols);
        }

        function getTeamCount(address user) external view returns (uint256) {
            return _getTeamCount(user, 0);
        }

        function _getTeamCount(address user, uint256 depth) internal view returns (uint256) {
            if (depth >= 8) {
                return 0;
            }
            uint256 count = 0;
            (,,address[] memory refs,) = IRecommendation(recommandContractAddress).getUserInfo(user);
            
            for (uint256 i = 0; i < refs.length; i++) {
                // 每一个直推算 1 个
                count += 1;
                // 再递归统计它的下级
                count += _getTeamCount(refs[i], depth + 1);
            }
            return count;
        }

        // 查询总量
        function getAllAirdropSumByUser(address user,uint256 productId) public view returns (uint256,uint256,uint256) {
            return (userInfos[msg.sender].airdropJwTime[productId],userInfos[user].airdropJwAmount[productId],userInfos[user].buyJWAmount[productId]);
        }

        // 查询阶段信息
        function getProduct(uint8 productId) public view returns(Product memory){
            return products[productId];
        }


    }