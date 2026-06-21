import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { IUniswapV2Router02,IUniswapV2Factory,IUniswapV2Pair,WPIJS,IPiJFactory,PiJFactory,PiJRouter,
    JW,PlatinumNFT,EpicNFT,LegendNFT,FlashSalse,PiJPair,PIJS_USDT,Recommendation,
    InteractionAirDrop,NFTSellManage,JWTradeMinner} from  "../../typechain-types";
import { network } from "hardhat";
import { Signer } from "ethers";

describe("JWSwap",async () => {

    let owner:any;
    let account1:any;
    let account2:any;
    let account3:any;
    let account4:any;
    let jw:JW;
    let platinumNFT:PlatinumNFT;
    let epicNFT:EpicNFT;
    let legendNFT:LegendNFT;
    let flashSalse:FlashSalse;
    let wpijs:WPIJS;
    let piJFactory:PiJFactory;
    let piJRouter:PiJRouter;
    let piOrangeJFactory:PiJFactory;
    let piOrangeJRouter:PiJRouter;
    const jwAddress = "0xd1F46DB3E2E332D1aF64BFbda785eB422f4187F3";
    const platinumNFTAddress = "0x602832375e571b87172546DcD2D7E41006b4e852";
    const epicNFTAddress = "0xD6669860c0a1C8A123c2760aE697D1AE83b6B861";
    const legendNFTAddress = "0xe86D824A1a43Dc241A7b94B6f42a1d13cAd5a282";
    const flashSalseAddress = "0x414eC87C4c27fE1c382333b6838D571AbBd5C32c";
    const wpijsAddress = "0x3749077a8D8a4fCFF10daAb9Bc130Ce4E609Ce54";
    const pijsFactoryAddress = "0x97490047CA48F96a451Fdc24C95b5E2d432EE588";
    const piJRouterAddress = "0x3D436e3503B40a2c73D0EA70ab407405aDaf13d5";
    const usdtAddress = "0xc4610478b18b116f88A2F22A8685467f970e7ffc";
    const nftSellManageAddress = "0x8B769E9BE8271e07a0ccb9b53E57d659D0963fe4";
    const recommandAddress = "0x27Bc64142dEd44c1d5b4FDA3E1A818b0d5C8Edb1";
    const interactionAirDropAddress = "0xF1bA312dD4fC43a1dc6a64bdE7a3Fe6121903e8e";
    const jWTradeMinnerAddress = "0x401fB5e3a679D6b0a6F8281cB59aD4E24d00cF74";

    const piOrangeFactoryAddress = "0xe3DCD243995ec02d0F4Fbf71A264A9453C15c7e1";
    const piJOrangeRouterAddress = "0x317A073A77b9Bdad986462eF87114aDA8876de67";

    let jwpair:PiJPair;
    let jwPairAddress:any;
    let usdt:PIJS_USDT;
    let usdtPair:PiJPair;
    let usdtPairAddress:any;
    let nftSellManage:NFTSellManage;
    let recommand:Recommendation;
    let interactionAirDrop:InteractionAirDrop;
    let jWTradeMinner:JWTradeMinner;
    let jw2usdtPairAddress:any;

    beforeEach(async () => {
        [owner,account1,account2,account3,account4] = await ethers.getSigners();
        jw = await ethers.getContractAt("JW",jwAddress);
        platinumNFT = await ethers.getContractAt("PlatinumNFT",platinumNFTAddress);
        epicNFT = await ethers.getContractAt("EpicNFT",epicNFTAddress);
        legendNFT = await ethers.getContractAt("LegendNFT",legendNFTAddress);
        flashSalse = await ethers.getContractAt("FlashSalse",flashSalseAddress);  
        wpijs = await ethers.getContractAt("WPIJS",wpijsAddress);
        piJFactory = await ethers.getContractAt("PiJFactory",pijsFactoryAddress);
        piJRouter = await ethers.getContractAt("PiJRouter",piJRouterAddress);
        jw2usdtPairAddress = await piJFactory.getPair(jwAddress,usdtAddress);
        console.log("jw/usdt pair address:",jw2usdtPairAddress);
        jwpair = await ethers.getContractAt("PiJPair", jw2usdtPairAddress);
        try {
            const reserves = await jwpair.getReserves();
            console.log("jw2usdt Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
            console.log("jw2usdt Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
            console.log("jw2usdt Pair token0:", await jwpair.token0());
            console.log("jw2usdt Pair token1:", await jwpair.token1());
        } catch (e) {
            console.log("jw2usdt Pair not initialized yet");
        }
        usdt = await ethers.getContractAt("PIJS_USDT",usdtAddress);
        
        piOrangeJFactory = await ethers.getContractAt("PiJFactory",piOrangeFactoryAddress);
        piOrangeJRouter =  await ethers.getContractAt("PiJRouter",piJOrangeRouterAddress);
        usdtPairAddress = await piOrangeJFactory.getPair(usdtAddress,wpijs.address);
        console.log("usdtPairAddress:",usdtPairAddress);
        usdtPair = await ethers.getContractAt("PiJPair", usdtPairAddress);
        try {
            const reserves = await usdtPair.getReserves();
            console.log("usdt2pijs Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
            console.log("usdt2pijs Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
            console.log("usdt2pijs Pair token0:", await usdtPair.token0());
            console.log("usdt2pijs Pair token1:", await usdtPair.token1());
        } catch (e) {
            console.log("usdt2pijs Pair not initialized yet");
        }

    

        nftSellManage = await ethers.getContractAt("NFTSellManage",nftSellManageAddress);
        recommand = await ethers.getContractAt("Recommendation",recommandAddress);
        interactionAirDrop = await ethers.getContractAt("InteractionAirDrop",interactionAirDropAddress);
        jWTradeMinner = await ethers.getContractAt("JWTradeMinner",jWTradeMinnerAddress);

        const userSwapNormal = await jw.getUserSwapNormals(account4.address);
        console.log("测试用户地址account4:",account4.address);
        console.log("totalHoldings:",ethers.utils.formatEther(userSwapNormal[0]));
        console.log("totalCost:",ethers.utils.formatEther(userSwapNormal[1]));



  
    });
    it("blank",async () => {
        // const usdt = await ethers.getContractAt("PIJS_USDT",usdtAddress);
        // const tx = await usdt.setTraseToPublic(true);
        // await tx.wait();
        console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("account4 usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(account4.address)));

        const t = await platinumNFT.tokenOfOwnerByIndex("0x693Dd8b5AA932F3b80aF7B797C6877086eb08a35",0);
        console.log("nft id:",t);

        
    });
    it("removeLiquidityJW2PIJS",async () => {
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        const lpBalance = await jwpair.balanceOf(owner.address);
        console.log("lpBalance:", lpBalance);
        // approve router 花费 LP Token
        const approveTx = await jwpair.connect(owner).approve(piJRouterAddress, lpBalance);
        await approveTx.wait();


        const removeTx = await piJRouter.connect(owner).removeLiquidityETH(
            jwAddress, // ERC20 代币地址
            lpBalance,         // 要移除的 LP Token 数量
            0, 
            0, 
            owner.address,     // 收取资金的地址
            deadline,          // 交易截止时间
            { gasLimit: 3000000 }
        );

        await removeTx.wait();

        const reservesAfterRemove = await jwpair.getReserves();
        console.log("reservesAfterRemove:",reservesAfterRemove);

    });
     it("removeLiquidityJW2USDT",async () => {
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        const lpBalance = await jwpair.balanceOf(owner.address);
        console.log("lpBalance:", lpBalance);
        // approve router 花费 LP Token
        const approveTx = await jwpair.connect(owner).approve(piJRouterAddress, lpBalance);
        await approveTx.wait();


        // const removeTx = await piJRouter.connect(owner).removeLiquidityETH(
        //     jwAddress, // ERC20 代币地址
        //     lpBalance,         // 要移除的 LP Token 数量
        //     0, 
        //     0, 
        //     owner.address,     // 收取资金的地址
        //     deadline,          // 交易截止时间
        //     { gasLimit: 3000000 }
        // );
        const removeTx = await piJRouter.connect(owner).removeLiquidity(
            jwAddress,
            usdtAddress,
            lpBalance,
            0,
            0,
            owner.address,
            deadline,
            { gasLimit: 3000000 }
        );

        await removeTx.wait();

        const reservesAfterRemove = await jwpair.getReserves();
        console.log("reservesAfterRemove:",reservesAfterRemove);

    });


    it("addLiquidityJW",async () => {

        const tx0 = await jw.setGlobalSellWhitelist(piJRouterAddress,true);
        await tx0.wait();
        const tx1 = await jw.updateGlobalBuyWhitelist(piJRouterAddress,true);
        await tx1.wait();

        const tx2 = await jw.setGlobalSellWhitelist(owner.address,true);
        await tx2.wait();
        const tx3 = await jw.updateGlobalBuyWhitelist(owner.address,true);
        await tx3.wait();
         const tx4 = await jw.updateGlobalBuyWhitelist(usdt.address,true);
        await tx4.wait();

        const tx000 = await jw.setTradeToPublic(true);
        await tx000.wait();


        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        console.log("Deadline:", deadline);
        try {
            // 2. 检查余额和批准
            const tokenAmount = ethers.utils.parseEther("500");
            const usdtAmount = ethers.utils.parseEther("100");
            
            const tokenBalance = await jw.balanceOf(owner.address);
            console.log("Token balance:", ethers.utils.formatEther(tokenBalance));

             const usdtBalance = await usdt.balanceOf(owner.address);
            console.log("usdtBalance balance:", ethers.utils.formatEther(usdtBalance));
            
            
            // 3. 先批准
            console.log("Approving tokens...");
            const approveTx = await jw.connect(owner).approve(
                piJRouter.address, 
                tokenAmount
            );
            await approveTx.wait();

            const approveTx1 = await usdt.connect(owner).approve(
                piJRouter.address, 
                usdtAmount
            );
            await approveTx1.wait();
            console.log("Approval confirmed");
            
            // 4. 检查批准状态
            const allowance = await jw.allowance(owner.address, piJRouter.address);
            console.log("Allowance:", ethers.utils.formatEther(allowance));
            const allowance2 = await usdt.allowance(owner.address, piJRouter.address);
            console.log("Allowance2:", ethers.utils.formatEther(allowance2));
            
            // 5. 设置滑点保护
            const amountTokenMin = tokenAmount.mul(70).div(100); // 10% 滑点
            const amountETHMin = usdtAmount.mul(70).div(100);    // 10% 滑点
            
            // 6. 添加流动性
            console.log("Adding liquidity...");
            // const tx = await piJRouter.connect(owner).addLiquidityETH(
            //     jw.address,
            //     tokenAmount,
            //     0,
            //     0,
            //     owner.address,
            //     deadline,
            //     {
            //         value: ethAmount,
            //         gasLimit: 6721975  // 先尝试标准gas limit
            //     }
            // );

            const tx2 = await piJRouter.connect(owner).addLiquidity(
                jw.address,
                usdtAddress,
                tokenAmount,
                usdtAmount,
                0,
                0,
                owner.address,
                deadline
            );
            const receipt = await tx2.wait();
            console.log("Transaction Hash:", receipt.transactionHash);
            console.log("Liquidity added successfully!");
            
        } catch (error) {
            console.error("Error details:", error);
        }

        // const reservesAfterRemove = await jwpair.getReserves();
        // console.log("reservesAfterRemove:",reservesAfterRemove);
    });

     it("addLiquidityToRaise",async () => {

        const tx0 = await jw.setGlobalSellWhitelist(piJRouterAddress,true);
        await tx0.wait();
        const tx1 = await jw.updateGlobalBuyWhitelist(piJRouterAddress,true);
        await tx1.wait();

        const tx2 = await jw.setGlobalSellWhitelist(owner.address,true);
        await tx2.wait();
        const tx3 = await jw.updateGlobalBuyWhitelist(owner.address,true);
        await tx3.wait();
         const tx4 = await jw.updateGlobalBuyWhitelist(usdt.address,true);
        await tx4.wait();

        const tx000 = await jw.setTradeToPublic(true);
        await tx000.wait();


        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        console.log("Deadline:", deadline);
        try {
            // 2. 检查余额和批准
            const tokenAmount = ethers.utils.parseEther("1");
            const usdtAmount = ethers.utils.parseEther("50");
            
            const tokenBalance = await jw.balanceOf(owner.address);
            console.log("Token balance:", ethers.utils.formatEther(tokenBalance));

            const usdtBalance = await usdt.balanceOf(owner.address);
            console.log("usdtBalance balance:", ethers.utils.formatEther(usdtBalance));
            
            
            // 3. 先批准
            console.log("Approving tokens...");
            const approveTx = await jw.connect(owner).approve(
                piJRouter.address, 
                tokenAmount
            );
            await approveTx.wait();

            const approveTx1 = await usdt.connect(owner).approve(
                piJRouter.address, 
                usdtAmount
            );
            await approveTx1.wait();
            console.log("Approval confirmed");
            
            // 4. 检查批准状态
            const allowance = await jw.allowance(owner.address, piJRouter.address);
            console.log("Allowance:", ethers.utils.formatEther(allowance));
            const allowance2 = await usdt.allowance(owner.address, piJRouter.address);
            console.log("Allowance2:", ethers.utils.formatEther(allowance2));
            
            // 5. 设置滑点保护
            const amountTokenMin = tokenAmount.mul(70).div(100); // 10% 滑点
            const amountETHMin = usdtAmount.mul(70).div(100);    // 10% 滑点
            
            // 6. 添加流动性
            console.log("Adding liquidity...");
            // const tx = await piJRouter.connect(owner).addLiquidityETH(
            //     jw.address,
            //     tokenAmount,
            //     0,
            //     0,
            //     owner.address,
            //     deadline,
            //     {
            //         value: ethAmount,
            //         gasLimit: 6721975  // 先尝试标准gas limit
            //     }
            // );

            const tx2 = await piJRouter.connect(owner).addLiquidity(
                jw.address,
                usdtAddress,
                tokenAmount,
                usdtAmount,
                0,
                0,
                owner.address,
                deadline
            );
            const receipt = await tx2.wait();
            console.log("Transaction Hash:", receipt.transactionHash);
            console.log("Liquidity added successfully!");
            
        } catch (error) {
            console.error("Error details:", error);
            
        }

        // const reservesAfterRemove = await jwpair.getReserves();
        // console.log("reservesAfterRemove:",reservesAfterRemove);
    });

    it("addLiquidityUSDT",async () => {
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        console.log("Deadline:", deadline);
        try {
            // 2. 检查余额和批准
            const tokenAmount = ethers.utils.parseEther("200");
            const ethAmount = ethers.utils.parseEther("10");
            
            const tokenBalance = await usdt.balanceOf(owner.address);
            console.log("Token balance:", ethers.utils.formatEther(tokenBalance));
            
            if (tokenBalance.lt(tokenAmount)) {
                console.log("Error: Insufficient token balance");
                return;
            }
            
            // 3. 先批准
            console.log("Approving tokens...");
            const approveTx = await usdt.connect(owner).approve(
                piJRouter.address, 
                tokenAmount
            );
            await approveTx.wait();
            console.log("Approval confirmed");
            
            // 4. 检查批准状态
            const allowance = await usdt.allowance(owner.address, piJRouter.address);
            console.log("Allowance:", ethers.utils.formatEther(allowance));
            
            // 5. 设置滑点保护
            const amountTokenMin = tokenAmount.mul(70).div(100); // 10% 滑点
            const amountETHMin = ethAmount.mul(70).div(100);    // 10% 滑点
            
            // 6. 添加流动性
            console.log("Adding liquidity...");
            const tx = await piJRouter.connect(owner).addLiquidityETH(
                usdt.address,
                tokenAmount,
                0,
                0,
                owner.address,
                deadline,
                {
                    value: ethAmount,
                    gasLimit: 6721975  // 先尝试标准gas limit
                }
            );

            const receipt = await tx.wait();
            console.log("Transaction Hash:", receipt.transactionHash);
            console.log("Liquidity added successfully!");
            
        } catch (error) {
            console.error("Error details:", error);
            
        }
    });
    it("jwParamCheck",async () => {
         // 检查开关
        console.log("检查交易是否整体开放(tradeToPublic):",await jw.tradeToPublic());
        console.log("购买只允许入金合约(buyLimitAddressSwitch):",await jw.buyLimitAddressSwitch());
        console.log("售出只允许入金合约(sellLimitAddressSwitch):",await jw.sellLimitAddressSwitch());
        console.log("允许购买(buyTradingEnabled):",await jw.getBuyTradingEnabled());
        console.log("允许售出(sellTradingEnabled):",await jw.getSellTradingEnabled());
        // 检查手续费地址
        const buyFeeReceiverCount = await jw.getBuyFeeReceiversCount();
        console.log("buyFeeReceiverCount:",buyFeeReceiverCount);
        for (let i = 0; i < buyFeeReceiverCount.toNumber();i++){
            console.log("buyFeeReceivers",i,":",await jw.getBuyFeeReceiver(i));
        }
        const sellFeeReceiverCount = await jw.getSellFeeReceiversCount();
        console.log("sellFeeReceiverCount:",sellFeeReceiverCount);
        for (let i = 0;i < sellFeeReceiverCount.toNumber();i++){
            console.log("sellFeeReceivers",i,":",await jw.getSellFeeReceiver(i));
        }

        const buyFeeReceiverCountNormal = await jw.getBuyFeeReceiversCountNormal();
        console.log("buyFeeReceiverCountNormal:",buyFeeReceiverCountNormal);
        for (let i = 0; i < buyFeeReceiverCountNormal.toNumber();i++){
            console.log("buyFeeReceiversNormal",i,":",await jw.buyFeeReceiversNormal(i));
        }
        
        const sellFeeReceiverCountNormal = await jw.getSellFeeReceiversCountNormal();
        console.log("sellFeeReceiverCountNormal:",sellFeeReceiverCountNormal);
        for (let i = 0;i < sellFeeReceiverCountNormal.toNumber();i++){
            console.log("sellFeeReceiversNormal",i,":",await jw.sellFeeReceiversNormal(i));
        }



        // // 检查白名单地址
        // console.log("router 是否在全局白名单:");
        // console.log(await jw.isGlobalWhitelisted(swapRouterAddress));
        // console.log("addLPPoolAddress 是否在全局白名单:");
        // console.log(await jw.isGlobalWhitelisted(owner.address));
        // console.log("入金合约是否在买入白名单(buyLimitAddressWhitelist):");
        // console.log(await jw.buyLimitAddressWhitelist(deposit_address));
        // console.log("入金合约是否在卖出白名单(sellLimitAddressWhitelist):");
        // console.log(await jw.sellLimitAddressWhitelist(deposit_address));



    });
    it("transferJW",async () => {
        // const user = "0x953022d715A3CbEaaF805412C7938F9830EEb122";
        // const user = "0x693Dd8b5AA932F3b80aF7B797C6877086eb08a35";
        const user = "0x3705d46dbbfb5cbfdd4d7c26e25ef7ef38697e9b";
        console.log(ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log(ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log(ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log(ethers.utils.formatEther(await jw.balanceOf(user)));
        console.log("interactionAirDropAddress:",ethers.utils.formatEther(await jw.balanceOf(interactionAirDropAddress)));
        

        const tx = await jw.connect(owner).transfer(interactionAirDropAddress,ethers.utils.parseEther("1000"));
        await tx.wait();

        // const tx = await jw.connect(owner).transfer(user,ethers.utils.parseEther("100000"));
        // await tx.wait();

        // const tx2 = await jw.connect(owner).transfer(account4.address,ethers.utils.parseEther("100"));
        // await tx2.wait();

        // const tx1 = await usdt.connect(owner).transfer(user,ethers.utils.parseEther("10000"));
        // await tx1.wait();

        console.log(ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log(ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log(ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log(ethers.utils.formatEther(await jw.balanceOf(user)));

        console.log("interactionAirDropAddress:",ethers.utils.formatEther(await jw.balanceOf(interactionAirDropAddress)));


    });

    it("recommand",async () => {
        console.log("account4 weth:",await ethers.provider.getBalance(account4.address));
        console.log("owner weth:",await ethers.provider.getBalance(owner.address));
        // const tx00 = await owner.sendTransaction({
        //     to:account4.address,
        //     value: ethers.utils.parseEther("10")
        // });
        // await tx00.wait();
        console.log("account4 weth:",await ethers.provider.getBalance(account4.address));
        console.log("owner weth:",await ethers.provider.getBalance(owner.address));
        // const tx = await recommand.connect(account4).register(account1.address);
        // await tx.wait();
        console.log("account4 info:",await recommand.getUserInfo(account4.address));
    });

    it("flashBuy-flashSalse",async () => {
        console.log("swapRounter:",await flashSalse.getRouterAddress());

        //get 5 usdt -> pijs
        const neededPijsAmount = await flashSalse.getUSDT2PIJS(ethers.utils.parseEther("5"));
        console.log("neededPijsAmount:",ethers.utils.formatEther(neededPijsAmount));

        console.log("before flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

        // const tx = await flashSalse.connect(account4).flashBuy(1,1,{
        //     value:ethers.utils.parseEther("2.5")
        // });
        // await tx.wait();

        console.log("after flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

    });

    it("flashBuy-queryOrder",async () => {
        const result = await flashSalse.checkingAllOrders(account4.address,1);
        console.log("checkingAllOrders:",result);

        const receivedResult = await flashSalse.checkingReceivedOrder(account4.address,1);
        console.log("checkingReceivedOrder:",receivedResult);

        const unReceivedResult = await flashSalse.checkingUnReceivedOrder(account4.address,1);
        console.log("checkingUnReceivedOrder:",unReceivedResult);

        const product = await flashSalse.getProduct(1);
        console.log("product:",product);

        const productInfo = await flashSalse.getProductAndUserLimit(1,account4.address);
        console.log("productInfo:",productInfo);
    });

    it("flashBuy-checkJW",async () => {
        console.log("before flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
        
        const tx0 = await flashSalse.connect(owner).setCanCheck(true,1);
        await tx0.wait();

        const tx = await flashSalse.connect(account4).checkJW(1,1);
        await tx.wait();

        console.log("after flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));


    });

    it("InteractionAirDrop-setParams",async () => {
        // const tx = await interactionAirDrop.connect(owner).setProduct(
        //     1,
        //     ethers.utils.parseEther("1"),
        //     5,
        //     50000,
        //     1,
        //     true,
        //     1770788894
        // );
        // await tx.wait();

        const product = await interactionAirDrop.getProduct(1);
        console.log("product 1:",product);
        const products = await interactionAirDrop.getProducts();
        console.log("products:",products);
    });
    it("InteractionAirDrop-joinAirDrop",async () => {
        //get 1 usdt -> pijs
        const neededPijsAmount = await nftSellManage.getUSDT2PIJS(ethers.utils.parseEther("1"));
        console.log("neededPijsAmount:",ethers.utils.formatEther(neededPijsAmount));

        console.log("before joinAirDrop account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before joinAirDrop account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before joinAirDrop flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before joinAirDrop receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before joinAirDrop recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
        const tx00 = await interactionAirDrop.connect(owner).setWearRate(50);
        await tx00.wait();
        const tx = await interactionAirDrop.connect(account4).joinAirDrop(1,{
            value:neededPijsAmount,
            gasLimit: 6721975  
        });
        await tx.wait();

        console.log("after joinAirDrop account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after joinAirDrop account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after joinAirDrop flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after joinAirDrop receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after joinAirDrop recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
    });

    it("InteractionAirDrop-queryOrder",async () => {
        const allorders = await  interactionAirDrop.checkingAllOrders("0x693Dd8b5AA932F3b80aF7B797C6877086eb08a35",1);
        console.log("checkingAllOrders:",allorders);

        const checkingWaitingExpireorder = await  interactionAirDrop.checkingWaitingExpire("0x693Dd8b5AA932F3b80aF7B797C6877086eb08a35",1);
        console.log("checkingWaitingExpireorder:",checkingWaitingExpireorder);

        // const receivedOrder = await  interactionAirDrop.checkPendingCollectionOrder("0x600A06CF3A0152cbd4b1b090432b3220653bD972",1);
        // console.log("receivedOrder:",receivedOrder);

        const pendingCollectionOrder = await  interactionAirDrop.checkPendingCollectionOrder("0x693Dd8b5AA932F3b80aF7B797C6877086eb08a35",1);
        console.log("pendingCollectionOrder:",pendingCollectionOrder);

        // console.log("getUserIntegration:",await interactionAirDrop.getUserIntegration("0x600A06CF3A0152cbd4b1b090432b3220653bD972"));
        // console.log("recommand:",await recommand.getUserInfo(account4.address));




    });

     it("InteractionAirDrop-checkJW",async () => {
        console.log("before checkJW account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before checkJW account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before checkJW flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before checkJW receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before checkJW recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
        
        const tx = await interactionAirDrop.connect(account4).checkJW(2,1);
        await tx.wait();

        console.log("after checkJW account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after checkJW account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after checkJW flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after checkJW receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after checkJW recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
     });

    it("NFTSellManage-BuyNFT",async () => {
        const buyJwAmount = await nftSellManage.getUSDT2JW(ethers.utils.parseEther("2100"));
        const buyPIJSAmount = await nftSellManage.getUSDT2PIJS(ethers.utils.parseEther("900"));
        console.log("buyJwAmount:",ethers.utils.formatEther(buyJwAmount));
        console.log("buyPIJSAmount:",ethers.utils.formatEther(buyPIJSAmount));

        console.log("before buyNFT account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before buyNFT flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before buyNFT receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before buyNFT receive JW balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("before buyNFT recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

        console.log("Approving tokens...");
        const approveTx = await jw.connect(account4).approve(
            nftSellManageAddress, 
            buyJwAmount
        );
        await approveTx.wait();
        console.log("Approval confirmed");
        
        // 检查批准状态
        const allowance = await jw.allowance(account4.address, nftSellManageAddress);
        console.log("Allowance:", ethers.utils.formatEther(allowance));

        const tx = await nftSellManage.connect(account4).buyNFT(
            buyJwAmount,
            buyPIJSAmount,
            jwAddress,
            ethers.utils.parseEther("3000"),
            legendNFTAddress,
            {
                value:buyPIJSAmount
            }
        );
        await tx.wait();

        console.log("after buyNFT account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after buyNFT flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after buyNFT receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after buyNFT receive JW balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("after buyNFT recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
    });

    it("NFTSellManage-nftBalance",async () => {
         console.log("account4 platinum balance:",await platinumNFT.balanceOf(account4.address));
         console.log("account4 epic balance:",await epicNFT.balanceOf(account4.address));
         console.log("account4 legend balance:",await legendNFT.balanceOf(account4.address));

         console.log("the platinumNFT owner",await platinumNFT.ownerOf(1));
         console.log("the epicNFT owner",await epicNFT.ownerOf(1));
         console.log("the legendNFT owner",await legendNFT.ownerOf(1));


    });
     it("NFTSellManage-getProduct",async () => {

     });


    it("JWTradeMinner-buyJW",async () => {
        console.log("before buyNFT account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before buyNFT receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before buyNFT receive JW balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("before buyNFT recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

        const tx = await jWTradeMinner.connect(account4).buyJW({
            value:ethers.utils.parseEther("10"),
            gasLimit: 6721975 
        });
        await tx.wait();

        console.log("after buyNFT account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after buyNFT receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after buyNFT receive JW balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("after buyNFT recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

         try {
            const reserves = await jwpair.getReserves();
            console.log("jwpair Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
            console.log("jwpair Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
            console.log("jwpair Pair token0:", await jwpair.token0());
            console.log("jwpair Pair token1:", await jwpair.token1());
        } catch (e) {
            console.log("jwpair Pair not initialized yet");
        }

    });

     it("JWTradeMinner-getParams",async () => {

        const tx00 = await jw.setLimitAddressSwitch(false,false);
        await tx00.wait();

        const tx = await jw.setSellLimitAddressWhitelist(jWTradeMinnerAddress,true);
        await tx.wait();
        const tx2 = await jw.setBuyLimitAddressWhitelist(jWTradeMinnerAddress, true);
        await tx2.wait();
        console.log("getParams:",await jWTradeMinner.getParams());
        console.log("sellLimitAddressSwitch:",await jw.sellLimitAddressSwitch());
        console.log("buyLimitAddressSwitch:",await jw.buyLimitAddressSwitch());
        console.log("sellLimitAddressWhitelist:",await jw.sellLimitAddressWhitelist(jWTradeMinnerAddress));
        console.log("buyLimitAddressWhitelist:",await jw.buyLimitAddressWhitelist(jWTradeMinnerAddress));

        console.log("sellTradingEnabled:",await jw.getSellTradingEnabled());
        console.log("buyLimitAddressSwitch:",await jw.buyLimitAddressSwitch());

        
     });

    it("jwswap",async () => {
        console.log("before buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        const tx = await piJRouter.connect(account4).swapExactETHForTokensSupportingFeeOnTransferTokens(
                0,
                [wpijsAddress, jwAddress],
                account4.address,
                deadline,
                { value: ethers.utils.parseEther("0.1") }
                );
         await tx.wait();
        console.log("after buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
    });

    it("JWTradeMinner-sellJW",async () => {
        console.log("before buyNFT account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before buyNFT receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before buyNFT receive JW balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("before buyNFT recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

        const tx00 = await jw.connect(account4).approve(jWTradeMinnerAddress,ethers.utils.parseEther("100"));
        await tx00.wait();

        const tx = await jWTradeMinner.connect(account4).sellJW(jwAddress,ethers.utils.parseEther("100"));
        await tx.wait();

        console.log("after buyNFT account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after buyNFT account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after buyNFT receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after buyNFT receive JW balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("after buyNFT recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

        try {
            const reserves = await jwpair.getReserves();
            console.log("jwpair Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
            console.log("jwpair Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
            console.log("jwpair Pair token0:", await jwpair.token0());
            console.log("jwpair Pair token1:", await jwpair.token1());
        } catch (e) {
            console.log("jwpair Pair not initialized yet");
        }
    });

    it("JWTradeMinner-calcaulateReward",async () => {
        console.log("queryRewardGenerateRecords:",await jWTradeMinner.queryRewardGenerateRecords(2026,account4.address));
        
        const tx = await jWTradeMinner.connect(account4).calcaulateReward({
            gasLimit: 6721975 
        });
        await tx.wait();

        console.log("queryRewardGenerateRecords:",await jWTradeMinner.queryRewardGenerateRecords(2026,account4.address));
        console.log("getUserInfo:",await jWTradeMinner.getUserInfo(account4.address));


    });
    it("JWTradeMinner-getRecord",async () => {
        console.log("getUserInfo:",await jWTradeMinner.getUserInfo(account4.address));

        console.log("getDayIndex",await jWTradeMinner.getDayIndex(1770272516));
        console.log("getYearIndex",await jWTradeMinner.getYearIndex(1770269230));
        console.log("getUserTradeTotal",await jWTradeMinner.getUserTradeTotal(account4.address));
        console.log("getUserTradePerDay",await jWTradeMinner.getUserTradePerDay(account4.address,491742));
        console.log("getPlatformTradeTotal",await jWTradeMinner.getPlatformTradeTotal());
        console.log("getPlatformTradePerDay",await jWTradeMinner.getPlatformTradePerDay(491742));
        console.log("getUserOrderIdsPerDay",await jWTradeMinner.getUserOrderIdsPerDay(account4.address,491742));
        console.log("getUserOrdersPerday",await jWTradeMinner.getUserOrdersPerday(account4.address,491742));
        console.log("queryRewardGenerateRecords",await jWTradeMinner.queryRewardGenerateRecords(2026,account4.address));


       
        // const _tradeVolumePerDay = [
        //     ethers.utils.parseEther("1000"),
        //     ethers.utils.parseEther("600"),
        //     ethers.utils.parseEther("500"),
        //     ethers.utils.parseEther("200"),
        // ];
        // const _produceTokenVolumePerDay = [
        //     ethers.utils.parseEther("300"),
        //     ethers.utils.parseEther("150"),
        //     ethers.utils.parseEther("100"),
        //     ethers.utils.parseEther("50"),
        // ];

        // const tx = await jWTradeMinner.connect(owner).setProduceTokenVolumePerDay(_tradeVolumePerDay,_produceTokenVolumePerDay);
        // await tx.wait();

        // console.log("getParams",await jWTradeMinner.getParams());


    });

    it("JWTradeMinner-receiveProduction",async () => {


        // const tx00 = await jw.connect(owner).transfer(jWTradeMinnerAddress,ethers.utils.parseEther("5000"));
        // await tx00.wait();

        console.log("before received:",ethers.utils.formatEther(await jw.balanceOf(jWTradeMinnerAddress)));

        const userinfo = await jWTradeMinner.getUserInfo(account4.address);
        console.log("getUserInfo:",userinfo);

        // const tx = await jWTradeMinner.connect(account4).receiveProduction(jwAddress,userinfo.dynRewardBalance,1);
        // await tx.wait();

        console.log("getUserInfo:",await jWTradeMinner.getUserInfo(account4.address));

        console.log("after received:",ethers.utils.formatEther(await jw.balanceOf(jWTradeMinnerAddress)));

        console.log("queryRewardReceivedRecord",await jWTradeMinner.queryRewardReceivedRecord(2026,account4.address));

    });

    it("jwswaptest",async () => {
        // pijs 购买 jw  先购买usdt，再购买jw--- 正常swap
        console.log("owner jw balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        // 购买usdt

        const path = [wpijs.address,jwAddress];
        const tx = await piJRouter.connect(account4).swapExactETHForTokensSupportingFeeOnTransferTokens(
            0,
            path,
            account4.address,
            deadline,
            { 
            value: ethers.utils.parseEther("0.5"),
            gasLimit: 350000 
            }
        );
        const receipent = await tx.wait();
        console.log("transactionHash:",receipent.transactionHash);


        

        console.log("owner jw balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));

        // 卖
        // console.log("owner jw balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        // console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        // console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        // console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        // const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        // const path = [jwAddress,wpijs.address];

        // const tx00 = await jw.connect(account4).approve(piJRouter.address,ethers.utils.parseEther("10"));
        // await tx00.wait();
        // const tx = await piJRouter.connect(account4).swapExactTokensForETHSupportingFeeOnTransferTokens(
        //     ethers.utils.parseEther("10"),
        //     0,
        //     path,
        //     account4.address,
        //     deadline,
        //     { 
        //         gasLimit: 350000 
        //     }
        // );
        // const receipent = await tx.wait();
        // console.log("transactionHash:",receipent.transactionHash);


        

        // console.log("owner jw balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        // console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        // console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        // console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));



        // 查看持仓
        
        console.log(await jw.getUserSwapNormals(account4.address));

        const userSwapNormal = await jw.getUserSwapNormals(account4.address);

        console.log("totalHoldings:",ethers.utils.formatEther(userSwapNormal[0]));
        console.log("totalCost:",ethers.utils.formatEther(userSwapNormal[1]));






        // 设置为全局白名单 无手续费交易
        // const tx00 = await jw.connect(owner).setGlobalSellWhitelist(account4.address,true);
        // await tx00.wait();

        // const tx01 = await jw.connect(owner).updateGlobalBuyWhitelist(account4.address,true);
        // await tx01.wait();


        // console.log("owner jw balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        // console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        // console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        // console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        // const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        // const path = [wpijs.address,jwAddress];
        // const tx = await piJRouter.connect(account4).swapExactETHForTokensSupportingFeeOnTransferTokens(
        //     0,
        //     path,
        //     account4.address,
        //     deadline,
        //     { 
        //     value: ethers.utils.parseEther("1"),
        //     gasLimit: 350000 
        //     }
        // );
        // const receipent = await tx.wait();
        // console.log("transactionHash:",receipent.transactionHash);

        // console.log("owner jw balance:",ethers.utils.formatEther(await jw.balanceOf(owner.address)));
        // console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        // console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        // console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        
    });

    it("jwtest2usdt",async () => {
        console.log("owner usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(owner.address)));
        console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("account4 usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(account4.address)));
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        // usdt 购买 jw
        const tx00 = await usdt.connect(account4).approve(piJRouter.address,ethers.utils.parseEther("0.5"));
        await tx00.wait();
        const path = [usdt.address,jwAddress];
        const tx = await piJRouter.connect(account4).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethers.utils.parseEther("0.5"),
            0,
            path,
            account4.address,
            deadline
        );
        const receipent = await tx.wait();
        console.log("transactionHash:",receipent.transactionHash);

        console.log("查看购买后的余额");
        console.log("owner usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(owner.address)));
        console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("account4 usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(account4.address)));

        // 查看持仓
        console.log(await jw.getUserSwapNormals(account4.address));
        const userSwapNormal = await jw.getUserSwapNormals(account4.address);
        console.log("totalHoldings:",ethers.utils.formatEther(userSwapNormal[0]));
        console.log("totalCost:",ethers.utils.formatEther(userSwapNormal[1]));
        

        // 卖
        // console.log("owner usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(owner.address)));
        // console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        // console.log("owner pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        // console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        // console.log("account4 usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(account4.address)));
        // const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        // const path = [jwAddress,usdtAddress];

        // const tx00 = await jw.connect(account4).approve(piJRouter.address,ethers.utils.parseEther("10"));
        // await tx00.wait();

        //  const tx = await piJRouter.connect(account4).swapExactTokensForTokensSupportingFeeOnTransferTokens(
        //     ethers.utils.parseEther("5"),
        //     0,
        //     path,
        //     account4.address,
        //     deadline,
        //     { 
        //         gasLimit: 350000 
        //     }
        //  );
        // const receipent = await tx.wait();
        // console.log("transactionHash:",receipent.transactionHash);


      
        console.log("account4 jw balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("account4 usdt balance:",ethers.utils.formatEther(await usdt.balanceOf(account4.address)));

    });

    it("getAmountOut",async () => {
        const jwAmount = ethers.utils.parseEther("10");
        const path = [jwAddress,usdtAddress];
        const amountOuts = await piJRouter.connect(account4).getAmountsOut(
            jwAmount,
            path
        );
        console.log("amountOuts:",amountOuts);
        console.log("amountOuts:",ethers.utils.formatEther(amountOuts[1]));

        
     });

    it("NFT-balance",async () => {
        const tx = await epicNFT.connect(owner).mint(account4.address);
        await tx.wait();
        console.log("platinumNFT account4 balance:",await platinumNFT.balanceOf(account4.address));
        console.log("epicNFT account4 balance:",await epicNFT.balanceOf(account4.address));
        console.log("legendNFT account4 balance:",await legendNFT.balanceOf(account4.address));

    });

    it("getmyInfo",async () => {
       console.log("getUserInfo:",await interactionAirDrop.getUserInfo("0xaDE3e15511dbA9781e6787342e9D4132DD0B80EC") );
       console.log("getUserIntegration:",await interactionAirDrop.getUserIntegration("0xaDE3e15511dbA9781e6787342e9D4132DD0B80EC") );

    });
       




});


/**
 
npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "blank"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "removeLiquidityJW2PIJS"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "removeLiquidityJW2USDT"


npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "addLiquidityJW"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "addLiquidityJWToRaise"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "jwParamCheck"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "transferJW"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "recommand"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "flashBuy-flashSalse"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "flashBuy-queryOrder"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "flashBuy-checkJW"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "InteractionAirDrop-setParams"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "InteractionAirDrop-joinAirDrop"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "InteractionAirDrop-queryOrder"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "InteractionAirDrop-checkJW"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "NFTSellManage-BuyNFT"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "NFTSellManage-nftBalance"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "JWTradeMinner-getParams"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "JWTradeMinner-buyJW"


npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "jwswap"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "JWTradeMinner-sellJW"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "JWTradeMinner-calcaulateReward"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "JWTradeMinner-getRecord"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "JWTradeMinner-receiveProduction"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "jwswaptest"

npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "jwtest2usdt"
npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "getAmountOut"
npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "NFT-balance"
\
npx hardhat test ./test/testnet/JWSwap_on_testnet.test.ts --network pijstestnet --grep "getmyInfo"






**/