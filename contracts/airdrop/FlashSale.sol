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
contract FlashSalse is  Initializable,
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
            address _jwToken,
            address _usdtAddress,
            address _receiver,
            address _recommandContractAddress,
            address _swapRouterAddress
        ) public initializer {
            __AccessControlEnumerable_init();
            __ReentrancyGuard_init();
            __UUPSUpgradeable_init();
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MANAGE_ROLE, msg.sender);
            jwToken = _jwToken;
            usdtAddress = _usdtAddress;
            receiver = _receiver;
            recommandContractAddress = _recommandContractAddress;
            swapRouterAddress = _swapRouterAddress;

            Product memory p1 = Product({
                productId : 1,
                usdtValue : 5 ether,
                buyLimit : 10,
                limit : 2000,
                currentSalseCopies:0,
                reconmmandRewardPercent:100,
                enabled : true,
                canCheck: false
            });
            products[1] = p1;

        }
        /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
        /////////////////////////////////////////////////////////////*/
        struct Product{
            uint8 productId;
            uint256 usdtValue;
            uint buyLimit;
            uint256 limit;
            uint256 currentSalseCopies;
            uint256 reconmmandRewardPercent;
            bool enabled;
            bool canCheck;
            
        }
        struct Order{
            uint256 orderId;
            address userAddr;
            uint256 pijsAmount;
            uint8 productId;
            uint256 copies;
            uint256 jwAmount;
            uint256 timestamp;
            bool isReceived;
            uint256 receivedTime;
        }
        address jwToken;
        address usdtAddress;
        address recommandContractAddress;
        address swapRouterAddress;
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
        event FlashBuy(address user,uint256 amount,address referrer,uint256 reconmmanderRewardAmount,uint256 currentOrderId,uint8 productId,uint256 copies,uint256 pijsAmount,uint256 timestamp);
        event CheckJW(address user,uint256 orderId,uint256 jwAmount,uint256 timestamp);


        /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
        //////////////////////////////////////////////////////////////*/
        function flashBuy(uint8 productId,uint8 copies) public payable nonReentrant {
            require(productId != 0,"Invaild product");
            require(copies != 0,"Invaild copies");
            require(products[productId].enabled == true,"product not enabled");
             (address referrer,,,) = IRecommendation(recommandContractAddress).getUserInfo(msg.sender);
            require(referrer != address(0),"user is not recommanded");
            require(msg.value>0,"value shoud >0");
            // 判断jw和pijs价值的usdt价值是否
            uint256 buyPIJSAmount2usd = getPIJS2USDT(msg.value);
            uint256 usdtValue = products[productId].usdtValue;
            require(buyPIJSAmount2usd >= usdtValue * copies * (DENOMINATOR - wearRate)/DENOMINATOR ,"the value of  pijs can not reached usdtValue");
             // limit
            uint256 userHasBuy = getUserBuyCopies(msg.sender,productId);
            require(userHasBuy < products[productId].buyLimit,"exceeded the buy limit");
            require(products[productId].currentSalseCopies + copies < products[productId].limit,"exceeded the product limit");

            // 直推奖励
            uint256 reconmmanderRewardAmount = msg.value * products[productId].reconmmandRewardPercent / DENOMINATOR;
            (bool ok, ) = referrer.call{value: reconmmanderRewardAmount}("");
            require(ok, "referrer received pijs transfer failed");

            uint256 currentOrderId = orderId;
            require(orders[currentOrderId].userAddr == address(0),"order existed");
            uint256 pijsAmount = msg.value;
            Order memory order = Order({
                orderId:currentOrderId,
                userAddr : msg.sender,
                pijsAmount : pijsAmount,
                productId:productId,
                copies : copies,
                jwAmount: msg.value,
                timestamp:block.timestamp,
                isReceived : false,
                receivedTime : 0
            });
            orders[currentOrderId] = order;
            userOrders[msg.sender][productId].push(currentOrderId);
            products[productId].currentSalseCopies = products[productId].currentSalseCopies + copies;
            orderId = orderId + 1;

            emit FlashBuy(msg.sender,msg.value,referrer,reconmmanderRewardAmount,currentOrderId,productId,copies,pijsAmount,block.timestamp);
        }

        function checkJW(uint256 _orderId,uint8 productId) public nonReentrant {
            require(products[productId].canCheck == true,"the function is not enabled");
             // is your's order
            Order memory order = orders[_orderId];
            require(order.userAddr != address(0),"the order is not exist");
            require(msg.sender == order.userAddr,"the owner of the order is not you");
            require(productId == order.productId,"the product is not correct");
            require(order.isReceived == false,"the order is already received");

            SafeERC20.safeTransferFrom(IERC20(jwToken), address(this) ,msg.sender, order.pijsAmount);
            
            orders[_orderId].isReceived = true;
            orders[_orderId].receivedTime = block.timestamp;

            emit CheckJW(msg.sender,order.orderId,order.jwAmount,block.timestamp);
        }

        /*//////////////////////////////////////////////////////////////
                            FUNCTIONS   setter  getter query
        //////////////////////////////////////////////////////////////*/
        function getProduct(uint8 productId) public view  returns(Product memory){
            return products[productId];
        }

        function getProductAndUserLimit(uint8 productId,address user) public view  returns(Product memory,uint256){
            uint256 userHasPurchased = getUserBuyCopies(user,productId);
            return (products[productId],userHasPurchased);
        }
        function getUserBuyCopies(address user,uint8 productId) public view returns(uint256){
            uint256 userBuyCopies;
            for (uint256 i = 0;i < userOrders[user][productId].length;i++){
                userBuyCopies = userBuyCopies + orders[userOrders[user][productId][i]].copies;
            }
            return userBuyCopies;
        }


        function setProduct(
            uint8 _productId,
            uint256 _usdtValue,
            uint _buyLimit,
            uint256 _limit,
            uint256 _reconmmandRewardPercent,
            bool _enabled,
            bool _canCheck) external onlyRole(MANAGE_ROLE) {
                
                products[_productId].productId = _productId;
                products[_productId].usdtValue = _usdtValue;
                products[_productId].buyLimit = _buyLimit;
                products[_productId].limit = _limit;
                products[_productId].reconmmandRewardPercent = _reconmmandRewardPercent;
                products[_productId].enabled = _enabled;
                products[_productId].canCheck = _canCheck;
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

        // 查询用户全部
        function checkingAllOrders (address user,uint8 productId) public view returns(Order[] memory){
            uint256[] memory orderIds = userOrders[user][productId];
            Order[] memory rorders = new Order[](orderIds.length);
            if (orderIds.length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].isReceived == true){
                        rorders[i]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            copies : orders[orderIds[i]].copies,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            timestamp: orders[orderIds[i]].timestamp,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime
                        });
                    }
                }
            }
            return rorders;
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
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].isReceived == true){
                        rorders[i]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            copies : orders[orderIds[i]].copies,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            timestamp: orders[orderIds[i]].timestamp,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime
                        });
                        amount = amount + orders[orderIds[i]].jwAmount;
                    }
                }
            }
             return (rorders,amount);
        }
        // 查询已领取
        function checkingUnReceivedOrder (address user,uint8 productId) public view returns(Order[] memory,uint256){
            uint256[] memory orderIds = userOrders[user][productId];
            uint256 length;
            uint256 amount;
            for (uint256 i = 0;i < orderIds.length;i++){
                 if (orders[orderIds[i]].isReceived == false){
                    length++;
                }
            }
            Order[] memory rorders = new Order[](length);
            if (length >0){
                for (uint256 i = 0;i < orderIds.length;i++){
                    if (orders[orderIds[i]].isReceived == false){
                        rorders[i]= Order({
                            orderId : orders[orderIds[i]].orderId,
                            userAddr : orders[orderIds[i]].userAddr,
                            pijsAmount : orders[orderIds[i]].pijsAmount,
                            productId: orders[orderIds[i]].productId,
                            copies : orders[orderIds[i]].copies,
                            jwAmount: orders[orderIds[i]].jwAmount,
                            timestamp: orders[orderIds[i]].timestamp,
                            isReceived:orders[orderIds[i]].isReceived,
                            receivedTime:orders[orderIds[i]].receivedTime
                        });
                        amount = amount + orders[orderIds[i]].jwAmount;
                    }
                }
            }
             return (rorders,amount);
        }

        



    }