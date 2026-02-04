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



#### 添加购买手续费接收者

```
function addBuyFeeReceiver(address _receiver, uint256 _rate) external onlyOwner
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



### NFT销售、分红 NFTSellManage

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





### JW挖矿、奖励  JWTradeMinner



#### 买JW

```
function buyJW() public payable nonReentrant 
```



#### 卖JW

```
function sellJW(address jwAddress,uint256 amount) public  nonReentrant 
```



#### 计算个人JW产出

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

#### 路由 IPiJRouter02

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

