# JWSWAP

## 测试网合约地址

------- 两个swap公用WPIJS、USDT

WPIJS contract address is: 0x3749077a8D8a4fCFF10daAb9Bc130Ce4E609Ce54

PIJS_USDT contract address is: 0xc4610478b18b116f88A2F22A8685467f970e7ffc

--------- orange swap

PiJFactory contract address is:  0xe3DCD243995ec02d0F4Fbf71A264A9453C15c7e1

PiJRouter contract address is: 0x317A073A77b9Bdad986462eF87114aDA8876de67

wpijs/usdt pair address: 0xc9E033a97913e9096B49e4F816Ab74fd0B853505

----------jwswap

PiJFactory contract address is:  0x97490047CA48F96a451Fdc24C95b5E2d432EE588

PiJRouter contract address is: 0x3D436e3503B40a2c73D0EA70ab407405aDaf13d5

JW contract address is: 0xf4Ac8fa7B1e88bB56e771A6C07A2d02FAfd03204

jw/usdt pair address: 0x26E03ADc2127a2D0bB346A401426ACB5AAE43D79

---------- 推荐合约

Recommendation address is: 0x27Bc64142dEd44c1d5b4FDA3E1A818b0d5C8Edb1

推荐的根地址:0x600A06CF3A0152cbd4b1b090432b3220653bD972

---------- NFT合约 （PlatinumNFT 铂金NFT、EpicNFT史诗NFT、LegendNFT传奇NFT）

PlatinumNFT contract address is: 0x602832375e571b87172546DcD2D7E41006b4e852
EpicNFT contract address is: 0xD6669860c0a1C8A123c2760aE697D1AE83b6B861
LegendNFT contract address is: 0xe86D824A1a43Dc241A7b94B6f42a1d13cAd5a282

---------- NFT销售管理合约 

NFTSellManage address is: 0x8B769E9BE8271e07a0ccb9b53E57d659D0963fe4

---------- 抢购合约

FlashSalse address is: 0x414eC87C4c27fE1c382333b6838D571AbBd5C32c

---------- 交互空投合约

InteractionAirDrop address is: 0xF1bA312dD4fC43a1dc6a64bdE7a3Fe6121903e8e

---------- JW挖矿合约

JWTradeMinner address is: 0x3040fa8370c61E26a7a244793a9EA15eC5C57bec









## ABI

### Recommendation 推荐 

Recommendation

#### 注册 register

```
function register(address referrerAddress)
```

- referrerAddress 推荐人

event

```
 event ReferralRegistered(address user,address referrer,address[] referralChain,uint256 timestamp);
```

- user 参与者地址
- referrer 推荐人地址
- referralChain 推荐链数组  [1直接推荐人,2间接推荐人,3,4....]
- timestamp 参与时间



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

#### totalSupply()

- 返回代币总供应量
- 返回值：`uint256`

#### balanceOf(address account)

- 返回 `account` 地址的余额
- 参数：`account`（地址）
- 返回值：`uint256`

#### transfer(address recipient, uint256 amount)

- 从调用者地址向 `recipient` 转账 `amount`
- 必须触发 `Transfer` 事件
- 返回值：`bool`（成功与否）

#### allowance(address owner, address spender)

- 返回 `owner` 授权给 `spender` 的额度
- 参数：`owner`（地址），`spender`（地址）
- 返回值：`uint256`

#### approve(address spender, uint256 amount)

- 授权 `spender` 从调用者地址转账 `amount`
- 必须触发 `Approval` 事件
- 返回值：`bool`

#### transferFrom(address sender, address recipient, uint256 amount)

- 从 `sender` 向 `recipient` 转账 `amount`，需有授权额度
- 必须触发 `Transfer` 事件
- 返回值：`bool`

#### 购买白名单设置

```
function updateGlobalBuyWhitelist(address _account, bool _status) external onlyOwner 
```

#### 批量设置购买白名单

```
function batchUpdateBuyGlobalWhitelist(address[] calldata _accounts, bool _status) external onlyOwner 
```

#### 设置购买开关

```
function updateBuyTradingEnabled(bool flag) external onlyOwner 
```

#### 查看购买开关的状态

```
function getSellTradingEnabled() public view returns(bool)
```



#### 售出白名单设置

```
 function setGlobalSellWhitelist(address _address, bool _state) public onlyOwner 
```



#### 批量设置售出白名单

```
function batchUpdateBuyGlobalWhitelist(address[] calldata _accounts, bool _status) external onlyOwner 
```

#### 设置售出开关

```
function updateBuyTradingEnabled(bool flag) external onlyOwner 
```

#### 查看售出开关状态

```
function getBuyTradingEnabled() public view returns(bool)
```

#### 批量设置出售手续费接收者

```
function setSellFeeReceivers(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner
```



#### 添加购买手续费接收者(挖矿交易)

```
function addBuyFeeReceiver(address _receiver, uint256 _rate) external onlyOwner
```

#### 添加购买手续费接收者(正常swap交易)

```
function setBuyFeeReceiversNormal(address[] calldata _receivers, uint256[] calldata _rates) external onlyOwner 
```



####  添加出售手续费接收者

```
function addBuyFeeReceiver(address _receiver, uint256 _rate) external onlyOwner 
```



#### 更新购买手续费接收者

```
function updateSellFeeReceiver(uint256 _index, address _receiver, uint256 _rate) external onlyOwner
```

####  删除购买手续费接收者

```
function removeBuyFeeReceiver(uint256 _index) external onlyOwner
```



#### 删除出售手续费接收者

```
 function removeSellFeeReceiver(uint256 _index) external onlyOwner 
```

#### 获取购买手续费接收者信息

```
function getBuyFeeReceiver(uint256 _index) external view returns (address receiver, uint256 rate) 
```

#### 获取购买手续费接收者信息

```
function getBuyFeeReceiver(uint256 _index) external view returns (address receiver, uint256 rate) 
```

####  获取所有购买手续费接收者

```
function getAllBuyFeeReceivers() external view returns (FeeReceiver[] memory) 
```

#### 获取出售手续费接收者信息

```
function getSellFeeReceiver(uint256 _index) external view returns (address receiver, uint256 rate) 
```



#### 设置购买、售出限制（用于交易所）

```
function setLimitAddressSwitch(bool _sellLimitAddressSwitch,bool _buyLimitAddressSwitch) public onlyOwner
```

#### 交易税事件

```
event ProfitDistribute(address from,address to,uint256 amount,uint256 timestamp);
```

- from
- to 交易税接收地址
- amount 交易税JW数量
- timestamp 时间

#### usdt2jw

```
 function getUSDT2JW(uint256 pijsAmount) public view returns(uint256)
```



#### 查询用户的持仓和成本

```
function getUserSwapNormals(address user) public view returns(UserSwapNormal memory)
```

```
struct UserSwapNormal {
        uint256 totalHoldings;
        uint256 totalCost;
    }
```

- totalHoldings 总持仓（JW）
- totalCost 总成本（USDT）



### NFT（PlatinumNFT 铂金NFT、EpicNFT史诗NFT、LegendNFT传奇NFT）

#### Metadata 元数据

##### name()

- 返回代币集合名称
- 返回值：string

##### symbol()

- 返回代币符号
- 返回值：string

##### tokenURI(uint256 tokenId)

- 返回 tokenId对应的元数据 URI
- 参数：`tokenId`（代币ID）
- 返回值：`string`

#### 查询方法

##### totalSupply()

- 返回已铸造的代币总数量
- 返回值：`uint256`

##### balanceOf(address owner)

- 返回 `owner` 地址拥有的代币数量
- 参数：`owner`（地址）
- 返回值：`uint256`

##### ownerOf(uint256 tokenId)

- 返回 `tokenId` 的所有者地址
- 参数：`tokenId`（代币ID）
- 返回值：`address`

#### 转账方法

##### safeTransferFrom(address from, address to, uint256 tokenId, bytes data)

- 将 `tokenId` 从 `from` 转账给 `to`，带安全检查
- 如果 `to` 是合约，必须调用 `onERC721Received`
- `data` 可包含额外数据
- 必须触发 `Transfer` 事件

##### safeTransferFrom(address from, address to, uint256 tokenId)

- 同上，`data` 为空

##### transferFrom(address from, address to, uint256 tokenId)

- 基础转账，不检查接收方是否支持 ERC721
- 必须触发 `Transfer` 事件

#### 授权方法

##### approve(address to, uint256 tokenId)

- 授权 `to` 地址操作特定的 `tokenId`
- 必须触发 `Approval` 事件

##### setApprovalForAll(address operator, bool approved)

- 授权或取消授权 `operator` 管理调用者的所有代币
- 必须触发 `ApprovalForAll` 事件

##### getApproved(uint256 tokenId)

- 返回 `tokenId` 的授权地址（单次授权）
- 参数：`tokenId`
- 返回值：`address`

##### isApprovedForAll(address owner, address operator)

- 检查 `operator` 是否被授权管理 `owner` 的所有代币
- 参数：`owner`（所有者），`operator`（操作者）
- 返回值：`bool`

#### 可选方法

##### supportsInterface(bytes4 interfaceId)

- ERC165 标准，用于检测合约支持的接口
- ERC721 的 `interfaceId` 为 `0x80ac58cd`

##### tokenByIndex(uint256 index)

- 枚举功能：通过索引获取代币ID（需实现可枚举扩展）
- 返回值：`uint256`

##### tokenOfOwnerByIndex(address owner, uint256 index)

- 枚举功能：通过索引获取所有者特定位置的代币ID
- 参数：`owner`（地址），`index`（索引）
- 返回值：`uint256`

#### MINT

##### mint(address receiver) external onlyRole(MANAGE_ROLE) returns (uint256)

mint单个给接收者

##### batchMint（address receiver,   uint amount ) external onlyRole(MANAGE_ROLE) 

批量mint

#### 权限控制

#####  _beforeTokenTransfer(  address from, address to, uint256 firstTokenId, uint256 batchSize  ) internal virtual override 

普通转账前的的控制

#####  updateTransferSwitch(bool _transferSwitch ) public onlyRole(MANAGE_ROLE)

转账开关

##### getCurrentId() public view returns(uint256)

获取当前最大nft id



### NFTSellManage NFT销售、分红 

#### 购买NFT

```
function buyNFT(uint256 buyJwAmount,uint256 buyPIJSAmount,address jwTokenAddress,uint256 usdtValue,address nftAddress) public payable nonReentrant
```

入参：

- buyJwAmount 支付的jw代币数量
- buyPIJSAmount 支付的PIJS数量
- jwTokenAddress JW代币地址
- usdtValue  usdt价值
- nftAddress nft地址仅限（PlatinumNFT 铂金NFT、EpicNFT史诗NFT、LegendNFT传奇NFT）

事件：

```
event  BuyNFT(address user,uint256 buyJwAmount,uint256 buyPIJSAmount,address nftAddress,uint256 nftId,
        uint256 dayIndex,uint256 currentOrderId,uint256 createTime);
```

- user 用户地址
- buyJwAmount 支付jw数量
- buyPIJSAmount 支付的pijs数量
- nftAddress nft地址
- nftId 购买到的nft
- dayIndex
- currentOrderId 当前订单id
- createTime 购买时间

#### 获取nft价格

```
 function getProduct(address productAddress) public view  returns(NFTProduct memory)
```

NFTProduct

- nftAddr nft地址

- usdtPrice 价格

- limit 购买限制

  



#### PIJS2USDT pijs兑换美元数量

```
 function getPIJS2USDT(uint256 amount) public view returns(uint256) 
```

入参：

- amount pijs的数量

返回值：

- usdt数量

#### getUSDT2PIJS usdt兑换pijs数量

```
function getUSDT2PIJS(uint256 amount) public view returns(uint256) 
```



#### getJW2USDT JW兑换USDT

```
function getJW2USDT(uint256 infoAmount) public view returns(uint256)
```



#### getUSDT2JW USDT兑换JW

```
function getUSDT2JW(uint256 usdtAmount) internal view returns(uint256) 
```



#### 获取购买订单

```
function getOrder(uint256 _orderId) external view returns(Order memory)
```

入参：

- _orderId 订单ID

返回值

Order

- orderId 订单ID
- product NFT地址
- nftId 
- purchasedJwAmount 支付的jw代币数量
- purchasedPIJSAmount 支付的pijs数量
- usdtValue usdt价值
- timestamp 订单创建时间

#### 生成奖励记录

```
function generateRewardOrder(address tokenAddress,uint256 tokenAmount,address nftAddress,uint256 nftId,address nftOwner,uint256 weekIndex,uint256 profitSharingAmount,uint256 feeSharingAmount) external onlyRole(OPERATE_ROLE) 
     
```



#### 领取奖励

```
function receiveReward(uint256 nftId,uint256 weekIndex,address nftAddress) public nonReentrant 
```



#### 查询分红记录

```
function queryReward(address user,uint256 year) public view returns(RewardOrder[] memory)
```





###  JWTradeMinner JW挖矿、奖励 



#### 买JW

```
function buyJW(address tokenAddress,uint256 tokenAmount) public  nonReentrant
```

入参：

- tokenAddress usdt地址
- tokenAmount usdt数量

事件：

```
 event BuyJW(address user,uint256 amountIn,uint256 amountOut,uint256 dayIndex,uint256 currentOrderId,
    uint256 userTradeTotalVol,uint256 userTradePerDayVol,uint256 platformTradeTotalVol,uint256 platformTradePerDayVol,uint256 createTime);
```

- user 用户地址
- amountIn usdt数量
- amountOut 购买到的jw数量
- dayIndex 日期
- currentOrderId 当前订单id nonce
- userTradeTotalVol 用户总交易量
- userTradePerDayVol 用户当天的交易量
- platformTradeTotalVol 平台总交易量
- platformTradePerDayVol 平台当天交易量
- createTime 购买时间



#### 卖JW

```
function sellJW(address jwAddress,uint256 amount) public  nonReentrant 
```

入参：

- jwAddress 
- amount jw数量

事件：

```
event SellJW(address user,uint256 amountIn,uint256 amountOut,uint256 dayIndex,uint256 currentOrderId,
    uint256 userTradeTotalVol,uint256 userTradePerDayVol,uint256 platformTradeTotalVol,uint256 platformTradePerDayVol,uint256 createTime);
```

- user 用户地址
- amountIn jw数量
- amountOut 得到usdt数量
- dayIndex 日期（第几天）
- currentOrderId 当前订单id
- userTradeTotalVol 用户总交易量
- userTradePerDayVol 用户当天的交易量
- platformTradeTotalVol 平台总交易量
- platformTradePerDayVol 平台当天交易量
- createTime 购买时间 

#### 计算个人JW产出（作废）

```
function calcaulateReward() public payable nonReentrant
```



#### 领取产出

```
 function receiveProduction(address token,uint256 amount,uint8 productionType) public nonReentrant
```



#### 查询产出记录

```
function queryRewardGenerateRecords(uint256 year,address user) public view returns(RewardGenerateRecord[] memory)
```

入参：

- year   年份 如：2026
- user 用户地址

返回值：

RewardGenerateRecord

- rewardGenerateId 生成记录ID
- tradeAmount 交易额
- recommandAmount
- staticProductionAmount
- dynProductionAmount
- timestamp

#### 领取产出记录

```
function queryRewardReceivedRecord(uint256 year,address user) public view returns(RewardReceivedRecord[] memory)
```

入参：

- year   年份 如：2026
- user 用户地址

返回值：

RewardReceivedRecord

- rewardReceivedOrderId
- productionType
- amount
- timestamp



### 空投

#### FlashSalse 抢购 

##### 购买

```
 function flashBuy(uint8 productId,uint8 copies,address tokenAddress,uint256 amount)
```

入参：

- productId 产品ID （目前填写1）
- copies 购买份数
- tokenAddress usdt合约地址
- amount 支付usdt数量

事件：

```
event FlashBuy(address user,uint256 amount,address referrer,uint256 reconmmanderRewardAmount,uint256 currentOrderId,uint8 productId,uint256 copies,uint256 timestamp);
```

- user 用户地址
- amount 支付usdt数量
- referrer 推荐人地址
- reconmmanderRewardAmount 推荐人接收到的usdt数量
- currentOrderId 当前订单id
- productId 产品id
- copies 购买数量
- timestamp 抢购时间



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

事件：

```
event CheckJW(address user,uint256 orderId,uint256 jwAmount,uint256 timestamp);
```

- user 用户地址
- orderId 订单id
- jwAmount 领取的jw数量
- timestamp 领取时间

##### 获取产品信息

```
  function getProduct(uint8 productId) public view  returns(Product memory)
```

入参：

- productId 产品id  第一期传 1

出参：

Product

- productId 产品id
- usdtValue 支付的usdt
- buyLimit 单地址限量
- limit 本产品限量
- jwAmountPerCopy 每份多少JW
- currentSalseCopies 当前卖出份数
- reconmmandRewardPercent 推荐者奖励比例
- enabled 是否启用
- canCheck 是否可以领取
- startTime 抢购开始时间

##### 获取产品信息和用户已购买份数

```
 function getProductAndUserLimit(uint8 productId,address user) public view  returns(Product memory,uint256)
```

Product

- productId 产品id
- usdtValue 支付的usdt
- buyLimit 单地址限量
- limit 本产品限量
- jwAmountPerCopy 每份多少JW
- currentSalseCopies 当前卖出份数
- reconmmandRewardPercent 推荐者奖励比例
- enabled 是否启用
- canCheck 是否可以领取
- startTime 抢购开始时间

uint256 用户已购买份数



#### InteractionAirDrop 交互空投 

##### 查询阶段信息

```
function getProduct(uint8 productId) public view returns(Product memory)
```

入参：

productId 1 一期 2 二期 3 三期

返回值：

Product

- uint8 productId 1 一期 2 二期 3 三期
- uint256 usdtValue 支付usdt数量
- uint256 jwAmountPerCopy 每份jw数量
- uint buyLimit 单用户购买限制
- uint256 limit 总限制
- uint256 currentInteractionTimes 当前交互总次数
-  uint256 realsePerioid  释放周期
- bool enabled  是否启用
-   uint256 startTime 开始上线时间

##### 参与空投

```
function joinAirDrop(uint8 productId) public 
```

入参：

- productId 1 一期 2 二期 3 三期

事件：

```
 event JoinAirDrop(address userAddr,uint8 productId,uint256 amount,address receiver,uint256 currentOrderId,address referrer,address indriectReferrer,uint256 driectReferrerIntegrationInc,uint256 inDriectReferrerIntegrationInc,uint256 timestamp);
```

- userAddr 参与者地址
- productId 1 一期 2 二期 3 三期
- amount 支付的pijs
- receiver 支付的pijs的接收者
- currentOrderId 订单id
- referrer 直接推荐人
- indriectReferrer 间接推荐人
- driectReferrerIntegrationInc  直接推荐人增加的积分
- inDriectReferrerIntegrationInc 简介推荐人增加的积分
- timestamp 时间戳



##### 购买同等数量JW

```
function purchaseSameQuantityJWWithUSDT(uint256 productId,uint256 _orderId,uint256 usdtAmount)
```

入参：

- productId 1 一期 2 二期 3 三期
- _orderId 订单ID
- usdtAmount usdt数量

事件：

```
event PurchaseSameQuantityJWWithUSDT(address userAddr,uint256 usdtAmount,uint256 jwReceived,uint256 timestamp);
```

- userAddr 用户地址
- usdtAmount 支付的usdt数量
- jwReceived 收到的jw数量
- timestamp 购买时间

##### 按期查询交互空投、支付金额

```
function getAllAirdropSumByUser(address user,uint256 productId) public view returns (uint256,uint256,uint256)
```

入参：

- user 用户地址
- productId 期

返回值：

- 时间
- 空投代币
- 支付金额



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
- purchaseSameQuantity 购买同等数量的JW
- purchaseSameQuantityTime  购买同等数量的JW 的时间
- isReceived 是否领
- receivedTime 领取时间

##### 查询待领取的 (待释放)

```
 function checkPendingCollectionOrder(address user,uint8 productId) public view returns(Order[] memory ,uint256)
```



##### 查询已领取

```
function checkingReceivedOrder (address user,uint8 productId) public view returns(Order[] memory,uint256)
```

##### 查询未到期（释放中）

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

事件：

```
 event CheckOrder(address userAddr,uint256 orderId,uint256 jwAmount,uint256 timestamp);
```

- userAddr 用户地址
- orderId 订单id
- jwAmount 领取的jw
- timestamp 领取时间



##### 查看用户积分

```
function getUserIntegration(address user) public view returns(uint256)
```



##### 查询直推用户数、查询推荐空投用户数、我的积分、推荐列表

```
function getUserInfo(address user) public view returns(uint256,uint256,uint256,RecomandCol[] memory) 
```

入参：

- user 用户地址

返回值：

- 推荐用户数
- 推荐空投用户数
- 我的积分
- 推荐列表

##### 查询我的团队总人数

```
function getTeamCount(address user) external view returns (uint256)
```

入参：

- user 用户地址

返回值：

- 团队人数

##### 查询全部产品信息

```
function getProducts() external view returns(Product memory,Product memory,Product memory)
```







### Swap

#### IPiJRouter02 路由 

路由接口，提供代币交换、流动性管理和价格计算功能。本接口兼容支持手续费代币的转移。 



##### 获取工厂合约地址

factory()



##### 添加流动性 addLiquidity

**参数**

| 参数             | 类型    | 描述                  |
| :--------------- | :------ | :-------------------- |
| `tokenA`         | address | 代币A地址             |
| `tokenB`         | address | 代币B地址             |
| `amountADesired` | uint    | 期望提供的代币A数量   |
| `amountBDesired` | uint    | 期望提供的代币B数量   |
| `amountAMin`     | uint    | 可接受的最小代币A数量 |
| `amountBMin`     | uint    | 可接受的最小代币B数量 |
| `to`             | address | 流动性代币接收地址    |
| `deadline`       | uint    | 交易过期时间戳        |

**返回**

- `amountA`: 实际添加的代币A数量
- `amountB`: 实际添加的代币B数量
- `liquidity`: 获得的流动性代币数量

##### addLiquidityETH

添加代币与 ETH 之间的流动性

**参数**

| 参数                 | 类型    | 描述                 |
| :------------------- | :------ | :------------------- |
| `token`              | address | 代币地址             |
| `amountTokenDesired` | uint    | 期望提供的代币数量   |
| `amountTokenMin`     | uint    | 可接受的最小代币数量 |
| `amountETHMin`       | uint    | 可接受的最小ETH数量  |
| `to`                 | address | 流动性代币接收地址   |
| `deadline`           | uint    | 交易过期时间戳       |

**注意**: 需要随交易发送 ETH

**返回**

- `amountToken`: 实际添加的代币数量
- `amountETH`: 实际添加的ETH数量
- `liquidity`: 获得的流动性代币数量

##### 移除流动性`removeLiquidity`

移除两个代币之间的流动性

**参数**

| 参数         | 类型    | 描述                   |
| :----------- | :------ | :--------------------- |
| `tokenA`     | address | 代币A地址              |
| `tokenB`     | address | 代币B地址              |
| `liquidity`  | uint    | 要销毁的流动性代币数量 |
| `amountAMin` | uint    | 可收到的最小代币A数量  |
| `amountBMin` | uint    | 可收到的最小代币B数量  |
| `to`         | address | 代币接收地址           |
| `deadline`   | uint    | 交易过期时间戳         |

**返回**

- `amountA`: 收到的代币A数量
- `amountB`: 收到的代币B数量

##### removeLiquidityETH

移除代币与 ETH 之间的流动性

**参数**

| 参数             | 类型    | 描述                   |
| :--------------- | :------ | :--------------------- |
| `token`          | address | 代币地址               |
| `liquidity`      | uint    | 要销毁的流动性代币数量 |
| `amountTokenMin` | uint    | 可收到的最小代币数量   |
| `amountETHMin`   | uint    | 可收到的最小ETH数量    |
| `to`             | address | 代币接收地址           |
| `deadline`       | uint    | 交易过期时间戳         |

**返回**

- `amountToken`: 收到的代币数量
- `amountETH`: 收到的ETH数量

##### 带许可的移除流动性removeLiquidityWithPermit

使用签名许可移除流动性（无需提前授权）

**参数**

| 参数         | 类型    | 描述                   |
| :----------- | :------ | :--------------------- |
| `tokenA`     | address | 代币A地址              |
| `tokenB`     | address | 代币B地址              |
| `liquidity`  | uint    | 要销毁的流动性代币数量 |
| `amountAMin` | uint    | 可收到的最小代币A数量  |
| `amountBMin` | uint    | 可收到的最小代币B数量  |
| `to`         | address | 代币接收地址           |
| `deadline`   | uint    | 交易过期时间戳         |
| `approveMax` | bool    | 是否授权最大数量       |
| `v`          | uint8   | 签名v值                |
| `r`          | bytes32 | 签名r值                |
| `s`          | bytes32 | 签名s值                |

**返回**

- `amountA`: 收到的代币A数量
- `amountB`: 收到的代币B数量

##### removeLiquidityETHWithPermit

使用签名许可移除 ETH 流动性

**参数**: 同上，但仅需一个代币地址

##### 代币交换

###### 精确输入交换swapExactTokensForTokens

用精确数量的输入代币交换输出代币

**参数**

| 参数           | 类型      | 描述                 |
| :------------- | :-------- | :------------------- |
| `amountIn`     | uint      | 精确输入数量         |
| `amountOutMin` | uint      | 可接受的最小输出数量 |
| `path`         | address[] | 交换路径数组         |
| `to`           | address   | 接收地址             |
| `deadline`     | uint      | 交易过期时间戳       |

**返回**

- `uint[]`: 实际交换数量数组

###### `swapExactETHForTokens`

用精确数量的 ETH 交换代币

**参数**

| 参数           | 类型      | 描述                         |
| :------------- | :-------- | :--------------------------- |
| `amountOutMin` | uint      | 可接受的最小输出数量         |
| `path`         | address[] | 交换路径（首地址必须是WETH） |
| `to`           | address   | 接收地址                     |
| `deadline`     | uint      | 交易过期时间戳               |

**注意**: 需要随交易发送 ETH

**返回**

- `uint[]`: 实际交换数量数组

###### `swapExactTokensForETH`

用精确数量的代币交换 ETH

**参数**

| 参数           | 类型      | 描述                         |
| :------------- | :-------- | :--------------------------- |
| `amountIn`     | uint      | 精确输入数量                 |
| `amountOutMin` | uint      | 可接受的最小ETH数量          |
| `path`         | address[] | 交换路径（末地址必须是WETH） |
| `to`           | address   | 接收地址                     |
| `deadline`     | uint      | 交易过期时间戳               |

**返回**

- `uint[]`: 实际交换数量数组

###### `swapTokensForExactTokens`

用代币交换精确数量的输出代币

**参数**

| 参数          | 类型      | 描述                 |
| :------------ | :-------- | :------------------- |
| `amountOut`   | uint      | 精确输出数量         |
| `amountInMax` | uint      | 可接受的最大输入数量 |
| `path`        | address[] | 交换路径数组         |
| `to`          | address   | 接收地址             |
| `deadline`    | uint      | 交易过期时间戳       |

**返回**

- `uint[]`: 实际交换数量数组

###### `swapETHForExactTokens`

用 ETH 交换精确数量的代币

**参数**

| 参数        | 类型      | 描述                         |
| :---------- | :-------- | :--------------------------- |
| `amountOut` | uint      | 精确输出数量                 |
| `path`      | address[] | 交换路径（首地址必须是WETH） |
| `to`        | address   | 接收地址                     |
| `deadline`  | uint      | 交易过期时间戳               |

**注意**: 需要随交易发送足够 ETH

**返回**

- `uint[]`: 实际交换数量数组

###### `swapTokensForExactETH`

用代币交换精确数量的 ETH

**参数**

| 参数          | 类型      | 描述                         |
| :------------ | :-------- | :--------------------------- |
| `amountOut`   | uint      | 精确输出ETH数量              |
| `amountInMax` | uint      | 可接受的最大输入数量         |
| `path`        | address[] | 交换路径（末地址必须是WETH） |
| `to`          | address   | 接收地址                     |
| `deadline`    | uint      | 交易过期时间戳               |

**返回**

- `uint[]`: 实际交换数量数组

##### 支持手续费代币的交换 (IPiJRouter02)

###### `swapExactTokensForTokensSupportingFeeOnTransferTokens`

支持手续费代币的精确输入交换

**参数**: 同 `swapExactTokensForTokens`
**返回**: 无返回值（直接转账）

###### `swapExactETHForTokensSupportingFeeOnTransferTokens`

支持手续费代币的 ETH 精确输入交换

**参数**: 同 `swapExactETHForTokens`
**注意**: 需要随交易发送 ETH
**返回**: 无返回值

###### `swapExactTokensForETHSupportingFeeOnTransferTokens`

支持手续费代币的代币精确输入交换ETH

**参数**: 同 `swapExactTokensForETH`
**返回**: 无返回值

###### `removeLiquidityETHSupportingFeeOnTransferTokens`

支持手续费代币的移除 ETH 流动性

**参数**: 同 `removeLiquidityETH`
**返回**: 收到的ETH数量

###### `removeLiquidityETHWithPermitSupportingFeeOnTransferTokens`

支持手续费代币的带许可移除 ETH 流动性

**参数**: 同 `removeLiquidityETHWithPermit`
**返回**: 收到的ETH数量

##### 价格计算

###### `quote`

根据储备计算理论输出数量（无手续费）

**参数**

| 参数       | 类型 | 描述         |
| :--------- | :--- | :----------- |
| `amountA`  | uint | 输入数量     |
| `reserveA` | uint | 输入代币储备 |
| `reserveB` | uint | 输出代币储备 |

**返回**

- `uint`: 理论输出数量

###### `getAmountOut`

计算实际输出数量（含0.25%手续费）

**参数**

| 参数         | 类型 | 描述         |
| :----------- | :--- | :----------- |
| `amountIn`   | uint | 输入数量     |
| `reserveIn`  | uint | 输入代币储备 |
| `reserveOut` | uint | 输出代币储备 |

**返回**

- `uint`: 实际输出数量

###### `getAmountIn`

计算所需输入数量（含0.25%手续费）

**参数**

| 参数         | 类型 | 描述         |
| :----------- | :--- | :----------- |
| `amountOut`  | uint | 期望输出数量 |
| `reserveIn`  | uint | 输入代币储备 |
| `reserveOut` | uint | 输出代币储备 |

**返回**

- `uint`: 所需输入数量

###### `getAmountsOut`

计算多路径交换的输出数量

**参数**

| 参数       | 类型      | 描述         |
| :--------- | :-------- | :----------- |
| `amountIn` | uint      | 输入数量     |
| `path`     | address[] | 交换路径数组 |

**返回**

- `uint[]`: 每个路径段的输出数量数组

###### `getAmountsIn`

计算多路径交换的输入数量

**参数**

| 参数        | 类型      | 描述         |
| :---------- | :-------- | :----------- |
| `amountOut` | uint      | 期望输出数量 |
| `path`      | address[] | 交换路径数组 |

**返回**

- `uint[]`: 每个路径段的输入数量数组

#### PiJFactory

PiJFactory 是 PiJ DEX 的工厂合约，负责创建和管理代币交易对。该合约基于 Uniswap V2 Factory 模式，使用 CREATE2 创建确定性地址的交易对合约。



##### allPairsLength()

获取已创建的交易对总数

```
function allPairsLength() external view returns (uint)
```

**返回**

- `uint`: 交易对总数



##### createPair(address tokenA, address tokenB)

创建新的代币交易对

```
function createPair(
    address tokenA,
    address tokenB
) external returns (address pair)
```

**参数**

| 参数     | 类型    | 描述           |
| :------- | :------ | :------------- |
| `tokenA` | address | 第一个代币地址 |
| `tokenB` | address | 第二个代币地址 |

**前提条件**

1. `tokenA != tokenB`（不能相同地址）
2. `tokenA` 和 `tokenB` 都不能是零地址
3. 交易对必须不存在

**验证错误**

| 错误消息                   | 条件                   |
| :------------------------- | :--------------------- |
| `PiJ: IDENTICAL_ADDRESSES` | `tokenA == tokenB`     |
| `PiJ: ZERO_ADDRESS`        | `token0 == address(0)` |
| `PiJ: PAIR_EXISTS`         | 交易对已存在           |

##### setFeeTo(address _feeTo)

设置协议手续费接收地址

**签名**

solidity

```
function setFeeTo(address _feeTo) external
```



**参数**

| 参数     | 类型    | 描述               |
| :------- | :------ | :----------------- |
| `_feeTo` | address | 新的手续费接收地址 |

**权限**: 仅 `feeToSetter` 可调用
**验证错误**: `PiJ: FORBIDDEN`（如果调用者不是 `feeToSetter`）

**用途**

- 设置协议手续费接收地址
- 设置为 `address(0)` 可关闭手续费

##### setFeeToSetter(address _feeToSetter)

转让手续费设置权限

**签名**

solidity

```
function setFeeToSetter(address _feeToSetter) external
```



**参数**

| 参数           | 类型    | 描述         |
| :------------- | :------ | :----------- |
| `_feeToSetter` | address | 新的权限地址 |

**权限**: 仅当前 `feeToSetter` 可调用
**验证错误**: `PiJ: FORBIDDEN`（如果调用者不是当前 `feeToSetter`）

**注意**: 此操作不可逆，请谨慎操作

#### PiJPair

##### initialize(address _token0, address _token1)

初始化交易对代币



```
function initialize(address _token0, address _token1) external
```



**参数**

| 参数      | 类型    | 描述           |
| :-------- | :------ | :------------- |
| `_token0` | address | 第一个代币地址 |
| `_token1` | address | 第二个代币地址 |

**权限**: 仅工厂合约可调用
**验证**: `require(msg.sender == factory, "PiJ: FORBIDDEN")`



##### getReserves()

获取当前储备金信息

```
function getReserves() public view returns (
    uint112 _reserve0,
    uint112 _reserve1,
    uint32 _blockTimestampLast
)
```



**返回**

- `_reserve0`: token0 当前储备量
- `_reserve1`: token1 当前储备量
- `_blockTimestampLast`: 最后更新时间戳



##### mint(address to)

添加流动性，铸造 LP 代币



```
function mint(address to) external lock returns (uint liquidity)
```



**参数**

| 参数 | 类型    | 描述            |
| :--- | :------ | :-------------- |
| `to` | address | LP 代币接收地址 |

**前提条件**

1. 调用者必须已将代币转入合约
2. 代币转入数量必须大于0

**执行流程**

1. 计算新增代币数量
2. 计算应铸造的流动性数量
3. 如果是首次铸造，锁定 `MINIMUM_LIQUIDITY`
4. 铸造 LP 代币给接收者
5. 更新储备金

**返回**

- `liquidity`: 铸造的 LP 代币数量

**计算公式**

- 首次铸造: `liquidity = √(amount0 * amount1) - MINIMUM_LIQUIDITY`
- 后续铸造: `liquidity = min(amount0 * totalSupply / reserve0, amount1 * totalSupply / reserve1)`

**验证错误**

| 错误                                 | 条件             |
| :----------------------------------- | :--------------- |
| `PiJ: INSUFFICIENT_LIQUIDITY_MINTED` | `liquidity == 0` |

**发出事件**

- `Mint(msg.sender, amount0, amount1)`



##### burn(address to)

移除流动性，销毁 LP 代币

```
function burn(address to) external lock returns (uint amount0, uint amount1)
```



**参数**

| 参数 | 类型    | 描述         |
| :--- | :------ | :----------- |
| `to` | address | 代币接收地址 |

**前提条件**

1. 调用者必须有足够的 LP 代币在合约中
2. 通常由 Router 合约调用

**执行流程**

1. 计算应返还的代币数量
2. 销毁 LP 代币
3. 转账代币给接收者
4. 更新储备金

**返回**

- `amount0`: 返还的 token0 数量
- `amount1`: 返还的 token1 数量

**计算公式**

- `amount0 = liquidity * balance0 / totalSupply`
- `amount1 = liquidity * balance1 / totalSupply`

**验证错误**

| 错误                                 | 条件                           |
| :----------------------------------- | :----------------------------- |
| `PiJ: INSUFFICIENT_LIQUIDITY_BURNED` | `amount0 == 0 || amount1 == 0` |

**发出事件**

- `Burn(msg.sender, amount0, amount1, to)`



##### swap(uint amount0Out, uint amount1Out, address to, bytes data)

执行代币交换

```
function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
) external lock
```



**参数**

| 参数         | 类型    | 描述               |
| :----------- | :------ | :----------------- |
| `amount0Out` | uint    | 输出的 token0 数量 |
| `amount1Out` | uint    | 输出的 token1 数量 |
| `to`         | address | 输出代币接收地址   |
| `data`       | bytes   | 回调数据（可选）   |

**前提条件**

1. 至少一个输出数量大于0
2. 输出数量小于储备金
3. 接收地址不能是代币合约本身
4. 满足恒定乘积公式（考虑手续费）

**执行流程**

1. 检查输出数量有效性
2. 转账输出代币
3. 如果设置了回调，调用 `PiJCall`
4. 计算输入数量
5. 验证恒定乘积
6. 更新储备金

**手续费计算**

- 交易手续费: 0.25%
- 调整后余额: `balance * 10000 - amountIn * 25`

**验证错误**

| 错误                              | 条件                                                         |
| :-------------------------------- | :----------------------------------------------------------- |
| `PiJ: INSUFFICIENT_OUTPUT_AMOUNT` | `amount0Out == 0 && amount1Out == 0`                         |
| `PiJ: INSUFFICIENT_LIQUIDITY`     | `amount0Out ≥ reserve0 || amount1Out ≥ reserve1`             |
| `PiJ: INVALID_TO`                 | `to == token0 || to == token1`                               |
| `PiJ: INSUFFICIENT_INPUT_AMOUNT`  | `amount0In == 0 && amount1In == 0`                           |
| `PiJ: K`                          | 不满足 `balance0Adjusted * balance1Adjusted ≥ reserve0 * reserve1 * 10000²` |

**发出事件**

- `Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to)`







