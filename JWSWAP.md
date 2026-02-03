# JWSWAP

## 合约地址







## ABI

### 推荐 Recommendation

Recommendation

#### 注册 register

```
function register(address referrerAddress)
```

- referrerAddress 推荐人



#### 获取用户的完整推荐信息 getUserInfo

```
function getUserReferralChains(address user) external view returns (
        address referrer,
        uint256 registrationTime,
        address[] memory directReferrals,
        address[] memory referralChain
    )
```

- user 用户地址

返回值

- referrer 推荐人
- registrationTime 注册时间
- directReferrals 直推地址
- referralChain 推荐链



#### 获取用户的推荐链getUserReferralChains

```
function getUserReferralChains(address user) external view returns(address[] memory)
```

入参：

- user 用户地址

返回值：

- referralChain 推荐链

#### 获取根地址getGenesisAddress

```
function getGenesisAddress() public view returns (address) 
```





### JW代币

JW

### NFT



### NFT销售、分红



### JW挖矿、奖励



### 空投

#### 抢购 FlashSalse

##### 购买

```
function flashBuy(uint8 productId,uint8 copies)
```

入参：

- productId 产品ID （目前填写1）
- copies 购买份数

##### 查询已领取

```
function checkingReceivedOrder (address user,uint8 productId) public view returns(Order[] memory,uint256,uint256)
```

入参：

- user 用户地址
- productId 产品ID （目前填写1）

返回值：

- Order[] 订单数组
  - orderId 订单ID
  - userAddr 购买人地址
  - pijsAmount 
  - productId
  - copies 份数
  - jwAmount 要领取的jw
  - timestamp 时间戳
  - isReceived 是否已领取
  - receivedTime 领取时间
- 要领取的jw总额
- 数量

##### 查询未领取

```
function checkingUnReceivedOrder (address user,uint8 productId) public view returns(Order[] memory,uint256)
```



##### 查询全部

```
function checkingAllOrders(address user,uint8 productId) public view returns(Order[] memory)
```



##### 领取

```
function checkJW(uint256 _orderId,uint8 productId) public nonReentrant 
```

入参：

- _orderId 订单ID
- productId 产品ID



#### 交互空投 InteractionAirDrop

##### 参与空投

```
function joinAirDrop(uint8 productId) public 
```

入参：

- productId 1 一期 2 二期 3 三期

##### 查询用户全部空投

```
 function checkingAllOrders (address user,uint8 productId) public view returns(Order[] memory)
```

入参：

- user 用户地址
- productId 期

返回值：

Order[] 

- orderId 空投订单ID
- userAddr 用户地址
- pijsAmount 交互的pijs数量
- productId 期
- jwAmount 可领取的jw
- createTime 创建时间
- isReceived 是否领
- receivedTime 领取时间

##### 查询待领取的

```
 function checkPendingCollectionOrder(address user,uint8 productId) public view returns(Order[] memory ,uint256)
```



##### 查询已领取

```
function checkingReceivedOrder (address user,uint8 productId) public view returns(Order[] memory,uint256)
```

##### 查询未到期

```
function checkingNotYetExpired(address user,uint8 productId) public view returns(Order[] memory,uint256 )
```

##### 获取交互次数

```
 function getInteractionTimes(address user,uint8 productId) public view returns(uint256,uint256,uint256,uint256)
```

入参：

- user 用户地址
- productId 期

返回值：

- limit 本期限制交互次数
- currentInteractionTimes 当前本期交互次数
- 本期剩余交互次数
- 用户本期剩余交互次数



##### 领取JW

```
function checkJW(uint256 _orderId,uint8 productId) public 
```

入参：

- user 用户地址
- productId 期



### Swap

