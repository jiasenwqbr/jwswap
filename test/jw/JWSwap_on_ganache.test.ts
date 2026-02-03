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
    const jwAddress = "0x277f645940F501D1D7D14d447073b43a55aC4Cb0";
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
    let jwpair:PiJPair;
    let jwPairAddress:any;
    let usdt:PIJS_USDT;
    let usdtPair:PiJPair;
    let usdtPairAddress:any;
    let nftSellManage:NFTSellManage;
    let recommand:Recommendation;
    let interactionAirDrop:InteractionAirDrop;

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
  
    });
    it("blank",async () => {});
    it("addLiquidity",async () => {

        // const tx0 = await jw.setGlobalSellWhitelist(piJRouterAddress,true);
        // await tx0.wait();
        // const tx1 = await jw.updateGlobalBuyWhitelist(piJRouterAddress,true);
        // await tx1.wait();

        // const tx2 = await jw.setGlobalSellWhitelist(owner.address,true);
        // await tx2.wait();
        // const tx3 = await jw.updateGlobalBuyWhitelist(owner.address,true);
        // await tx3.wait();

        const tx000 = await jw.setTradeToPublic(true);
        await tx000.wait();


        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        console.log("Deadline:", deadline);
        try {
            // 2. 检查余额和批准
            const tokenAmount = ethers.utils.parseEther("100");
            const ethAmount = ethers.utils.parseEther("10");
            
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
    it("transferJW",async () => {
        const tx = await jw.connect(owner).transfer(flashSalseAddress,ethers.utils.parseEther("100000"));
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

        const tx = await flashSalse.connect(account4).checkJW(1,1);
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
        
        const tx = await interactionAirDrop.connect(account4).checkJW(0,1);
        await tx.wait();

        console.log("after checkJW account4 pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account4.address)));
        console.log("after checkJW account4 JW balance:",ethers.utils.formatEther(await jw.balanceOf(account4.address)));
        console.log("after checkJW flashSalseAddress JW balance:",ethers.utils.formatEther(await jw.balanceOf(flashSalseAddress)));
        console.log("after checkJW receive pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
        console.log("after checkJW recommander pijs balance:",ethers.utils.formatEther(await ethers.provider.getBalance(account1.address)));
     });

     it("NFTSellManage",async () => {
        
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
**/