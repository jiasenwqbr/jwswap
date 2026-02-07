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
            address _receiver,
            address _recommandContractAddress,
            address _swapRouterAddress,
            address _swapOrangeRouterAddress,
            address _jwToken,
            uint256 _wearRate
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
            swapOrangeRouterAddress = _swapOrangeRouterAddress;
            jwToken = _jwToken;
            wearRate = _wearRate;

            Product memory p1 = Product({
                productId : 1,
                usdtValue: 1 ether,
                jwAmountPerCopy:500 ether,
                buyLimit : 5,
                limit:50000,
                currentInteractionTimes:0,
                realsePerioid: 24,
                enabled : true
            });
            Product memory p2 = Product({
                productId : 1,
                usdtValue: 1 ether,
                jwAmountPerCopy:500 ether,
                buyLimit : 5,
                limit:50000,
                currentInteractionTimes:0,
                realsePerioid: 24,
                enabled : false
            });
            Product memory p3 = Product({
                productId : 1,
                usdtValue: 1 ether,
                jwAmountPerCopy:500 ether,
                buyLimit : 5,
                limit:50000,
                currentInteractionTimes:0,
                realsePerioid: 24,
                enabled : false
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
        }
        address jwToken;
        address usdtAddress;
        address recommandContractAddress;
        address swapRouterAddress;
        address swapOrangeRouterAddress;
        address receiver;
        uint256 public constant SECONDS_PER_HOUR = 60 * 60;
        uint256 orderId;
        uint256 public wearRate;
        uint256 public constant DENOMINATOR = 1000;
        mapping(uint8 => Product) products;
        mapping(uint256 => Order) orders;
        mapping(address => mapping(uint8 => uint256[])) userOrders;
        
        /*//////////////////////////////////////////////////////////////
                            EVENTS
        //////////////////////////////////////////////////////////////*/
        event JoinAirDrop(address userAddr,uint8 productId,uint256 amount,address receiver,uint256 currentOrderId,uint256 timestamp);
        event CheckOrder(address userAddr,uint256 orderId,uint256 jwAmount,uint256 timestamp);

        /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
        //////////////////////////////////////////////////////////////*/
        function joinAirDrop(uint8 productId) public payable nonReentrant {
            require(productId != 0,"Invaild product");
            require(products[productId].enabled == true,"product not enabled");
            (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
            require(referrer != address(0),"user is not recommanded");
            require(msg.value>0,"value shoud >0");
            // 判断jw和pijs价值的usdt价值是否
            uint256 buyPIJSAmount2usd = getPIJS2USDT(msg.value);
            uint256 usdtValue = products[productId].usdtValue;
            require(buyPIJSAmount2usd >= usdtValue * (DENOMINATOR - wearRate)/DENOMINATOR ,"the value of  pijs can not reached usdtValue");
            // limit
            require(userOrders[msg.sender][productId].length < products[productId].buyLimit,"exceeded the buy limit");
            require(products[productId].currentInteractionTimes < products[productId].limit,"exceeded the product limit");

            // receiver
            (bool ok1, ) = receiver.call{value: msg.value }("");
            require(ok1, "referrer received pijs transfer failed");
            
            uint256 currentOrderId = orderId;
            require(orders[currentOrderId].userAddr == address(0),"order existed");
            Order memory order = Order({
                orderId:currentOrderId,
                userAddr : msg.sender,
                pijsAmount : msg.value,
                productId:productId,
                jwAmount: products[productId].jwAmountPerCopy,
                createTime:block.timestamp,
                isReceived:false,
                receivedTime:0
            });
            orders[currentOrderId] = order;
            userOrders[msg.sender][productId].push(currentOrderId);
            products[productId].currentInteractionTimes = products[productId].currentInteractionTimes +1;
            orderId = orderId + 1;
            emit JoinAirDrop(msg.sender,productId,msg.value,receiver,currentOrderId,block.timestamp);
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

            SafeERC20.safeTransfer(IERC20(jwToken), msg.sender, order.pijsAmount);

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

        // 查询待领取的
        function checkPendingCollectionOrder(address user,uint8 productId) public view returns(Order[] memory ,uint256){
            uint256[] memory orderIds = userOrders[user][productId];
            uint256 amount;
            uint256 length;
            for (uint256 i = 0;i < orderIds.length;i++){
                if (orders[orderIds[i]].createTime <= block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                    length++;
                }
            }
            Order[] memory rorders = new Order[](length);
            uint256 index;
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].createTime <= block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                        rorders[index]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            createTime: orders[orderIds[i]].createTime,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime
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
                            receivedTime:orders[orderIds[i]].receivedTime
                        });
                        amount = amount + orders[orderIds[i]].jwAmount;
                        index = index+1;
                    }
                }
            }
             return (rorders,amount);
        }
        // 查询未到期
        function checkingNotYetExpired(address user,uint8 productId) public view returns(Order[] memory,uint256 ){
            uint256[] memory orderIds = userOrders[user][productId];
            uint256 length;
            uint256 amount;
            for (uint256 i = 0;i < orderIds.length;i++){
                if (orders[orderIds[i]].createTime > block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                    length++;
                }
            }
            Order[] memory rorders = new Order[](length);
            uint256 index;
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].createTime > block.timestamp - products[productId].realsePerioid * SECONDS_PER_HOUR){
                        rorders[index]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            createTime: orders[orderIds[i]].createTime,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime
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
                            receivedTime:orders[orderIds[i]].receivedTime
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

        function getProduct(uint8 productId) public view  returns(Product memory){
            return products[productId];
        }

        function setProduct(
            uint8 _productId,
            uint256 _usdtValue,
            uint _buyLimit,
            uint256 _limit,
            uint256 _realsePerioid,
            bool _enabled) external onlyRole(MANAGE_ROLE) {

                products[_productId].productId = _productId;
                products[_productId].usdtValue = _usdtValue;
                products[_productId].buyLimit = _buyLimit;
                products[_productId].limit = _limit;
                products[_productId].realsePerioid = _realsePerioid;
                products[_productId].enabled = _enabled;
        }

        function setWearRate(uint256 _wearRate)external onlyRole(MANAGE_ROLE) {
            wearRate = _wearRate;
        }


    }