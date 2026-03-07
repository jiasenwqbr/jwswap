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
    const jwAddress = "0x29d14b0b09f219D9583C5A6BB9772DA6B10ad593";
    const platinumNFTAddress = "0x1FfbaEd0D022CA599351E2877365F670FE900a5f";
    const epicNFTAddress = "0x134b45aB7d3f37513b788dAa0149d48f3D02B007";
    const legendNFTAddress = "0xf37d3CD10fE2C11dc4c5dCFA5502A072eC9f501a";
    const flashSalseAddress = "0x1F5c0240e23d81E8a5438C8062CC06f2022581e8";
    const wpijsAddress = "0x6779A181d9129042D32708bFBf7067d44659D3f0";
    const pijsFactoryAddress = "0x246c1E66BFd681f1b8f7891697336498bE403ba5";
    const piJRouterAddress = "0x22caD33A0376886F8a85fcbfa4512763C1994768";
    const usdtAddress = "0x5aCB1D3c7C6767b7601C46370bdEcB4707193944";
    const nftSellManageAddress = "0xC62D7FE8BE64991E6f8d3F8A482D4fE530d46fd1";
    const recommandAddress = "0x336ABF2509ca960f369f0aa263f4713be42209A9";
    const interactionAirDropAddress = "0x246AEcE8799E1d4E264B76a703aF9F9951E4D6Bc";
    const jWTradeMinnerAddress = "0xa7E3A1637BEdeD9F5a605a700D8046176CF2A8Fc";

    let jwpair:PiJPair;
    let jwPairAddress:any;
    let usdt:PIJS_USDT;
    let usdtPair:PiJPair;
    let usdtPairAddress:any;
    let nftSellManage:NFTSellManage;
    let recommand:Recommendation;
    let interactionAirDrop:InteractionAirDrop;
    let jWTradeMinner:JWTradeMinner;

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
        jwPairAddress = await piJFactory.getPair(jwAddress,wpijs.address);
        console.log("jw/wpijs pair address:",jwPairAddress);
        jwpair = await ethers.getContractAt("PiJPair", jwPairAddress);
        try {
            const reserves = await jwpair.getReserves();
            console.log("jwpair Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
            console.log("jwpair Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
            console.log("jwpair Pair token0:", await jwpair.token0());
            console.log("jwpair Pair token1:", await jwpair.token1());
        } catch (e) {
            console.log("jwpair Pair not initialized yet");
        }
        usdt = await ethers.getContractAt("PIJS_USDT",usdtAddress);
        usdtPairAddress = await piJFactory.getPair(usdtAddress,wpijs.address);
        console.log("usdtPairAddress:",usdtPairAddress);
        usdtPair = await ethers.getContractAt("PiJPair", usdtPairAddress);
        try {
            const reserves = await usdtPair.getReserves();
            console.log("usdtPair Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
            console.log("usdtPair Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
            console.log("usdtPair Pair token0:", await usdtPair.token0());
            console.log("usdtPair Pair token1:", await usdtPair.token1());
        } catch (e) {
            console.log("usdtPair Pair not initialized yet");
        }

        nftSellManage = await ethers.getContractAt("NFTSellManage",nftSellManageAddress);
        recommand = await ethers.getContractAt("Recommendation",recommandAddress);
        interactionAirDrop = await ethers.getContractAt("InteractionAirDrop",interactionAirDropAddress);
        jWTradeMinner = await ethers.getContractAt("JWTradeMinner",jWTradeMinnerAddress);
  
    });
    it("blank",async () => {});
    it("addLiquidity",async () => {

        const tx0 = await jw.setGlobalSellWhitelist(piJRouterAddress,true);
        await tx0.wait();
        const tx1 = await jw.updateGlobalBuyWhitelist(piJRouterAddress,true);
        await tx1.wait();

        const tx2 = await jw.setGlobalSellWhitelist(owner.address,true);
        await tx2.wait();
        const tx3 = await jw.updateGlobalBuyWhitelist(owner.address,true);
        await tx3.wait();

        const tx000 = await jw.setTradeToPublic(true);
        await tx000.wait();


        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        console.log("Deadline:", deadline);
        try {
            // 2. 检查余额和批准
            const tokenAmount = ethers.utils.parseEther("50");
            const ethAmount = ethers.utils.parseEther("5");
            
            const tokenBalance = await jw.balanceOf(owner.address);
            console.log("Token balance:", ethers.utils.formatEther(tokenBalance));
            
            if (tokenBalance.lt(tokenAmount)) {
                console.log("Error: Insufficient token balance");
                return;
            }
            
            // 3. 先批准
            console.log("Approving tokens...");
            const approveTx = await jw.connect(owner).approve(
                piJRouter.address, 
                tokenAmount
            );
            await approveTx.wait();
            console.log("Approval confirmed");
            
            // 4. 检查批准状态
            const allowance = await jw.allowance(owner.address, piJRouter.address);
            console.log("Allowance:", ethers.utils.formatEther(allowance));
            
            // 5. 设置滑点保护
            const amountTokenMin = tokenAmount.mul(70).div(100); // 10% 滑点
            const amountETHMin = ethAmount.mul(70).div(100);    // 10% 滑点
            
            // 6. 添加流动性
            console.log("Adding liquidity...");
            const tx = await piJRouter.connect(owner).addLiquidityETH(
                jw.address,
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

    it("add-LiquidityUSDT",async () => {
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
    it("transferJW",async () => {
        const tx = await jw.connect(owner).transfer("0x953022d715A3CbEaaF805412C7938F9830EEb122",ethers.utils.parseEther("100000"));
        await tx.wait();
        console.log(ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));

    });

    it("recommand",async () => {
        const tx = await recommand.connect(account4).register(account1.address);
        await tx.wait();
        console.log("account4 info:",await recommand.getUserInfo(account4.address));
    });

    it("flashBuy",async () => {

        //get 5 usdt -> pijs
        const neededPijsAmount = await nftSellManage.getUSDT2PIJS(ethers.utils.parseEther("5"));
        console.log("neededPijsAmount:",ethers.utils.formatEther(neededPijsAmount));

        console.log("before flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));

        const tx = await flashSalse.connect(account4).flashBuy(1,1,{
            value:ethers.utils.parseEther("2.5")
        });
        await tx.wait();

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
    });

    it("flashBuy-checkJW",async () => {
        console.log("before flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
        
        const tx0 = await flashSalse.connect(owner).setCanCheck(true,1);
        await tx0.wait();

        const tx = await flashSalse.connect(account4).checkJWs(1);
        await tx.wait();

        console.log("after flash account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after flash account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after flash flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after flash receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after flash recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));


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
            value:ethers.utils.parseEther("0.05"),
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
        const allorders = await  interactionAirDrop.checkingAllOrders(account4.address,1);
        console.log("checkingAllOrders:",allorders);

        const notYetExpired = await  interactionAirDrop.checkingNotYetExpired(account4.address,1);
        console.log("notYetExpired:",notYetExpired);

        const receivedOrder = await  interactionAirDrop.checkingReceivedOrder(account4.address,1);
        console.log("receivedOrder:",receivedOrder);

        const pendingCollectionOrder = await  interactionAirDrop.checkPendingCollectionOrder(account4.address,1);
        console.log("pendingCollectionOrder:",pendingCollectionOrder);
    });

     it("InteractionAirDrop-checkJW",async () => {
        console.log("before checkJW account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("before checkJW account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("before checkJW flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("before checkJW receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("before checkJW recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
        
        const tx = await interactionAirDrop.connect(account4).checkJWs(1);
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
       




});


/**
 
npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "blank"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "addLiquidity"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "addLiquidityUSDT"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "transferJW"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "recommand"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "flashBuy"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "flashBuy-queryOrder"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "flashBuy-checkJW"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "InteractionAirDrop-joinAirDrop"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "InteractionAirDrop-queryOrder"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "InteractionAirDrop-checkJW"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "NFTSellManage-BuyNFT"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "NFTSellManage-nftBalance"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "JWTradeMinner-getParams"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "JWTradeMinner-buyJW"


npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "jwswap"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "JWTradeMinner-sellJW"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "JWTradeMinner-calcaulateReward"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "JWTradeMinner-getRecord"

npx hardhat test ./test/jw/JWSwap_on_ganache.test.ts --network ganache --grep "JWTradeMinner-receiveProduction"





**/