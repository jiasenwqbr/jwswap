import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { network } from "hardhat";
import { Signer } from "ethers";
import { IUniswapV2Router02,IUniswapV2Factory,IUniswapV2Pair,PiJPair,WPIJS,IPiJFactory,PiJRouter,JWERC20, PiJFactory} from  "../../typechain-types";


describe("DepositContract.test",()=>{
    let owner:any;
    let account1:any;
    let account2:any;
    let account3:any;
    let account4:any;
    const jwAddress = "0x4a324E373385eb6253BBc75715877F06650aA0CC";
    const wpijsAddress = "0x6779A181d9129042D32708bFBf7067d44659D3f0";
    const piJFactoryAddress = "0x246c1E66BFd681f1b8f7891697336498bE403ba5";
    const piJRouterAddress = "0x22caD33A0376886F8a85fcbfa4512763C1994768";
    let jWERC20:JWERC20;
    let wpijs:WPIJS;
    let piJFactory:PiJFactory;
    let piJRouter:PiJRouter;
    let jw2pijsPair:PiJPair;
    let jw2pijsPairAddress:any;

    beforeEach(async () => {
        [owner, account1, account2, account3, account4] = await ethers.getSigners();
        jWERC20 = await ethers.getContractAt("JWERC20",jwAddress);
        wpijs = await ethers.getContractAt("WPIJS",wpijsAddress);
        piJFactory = await ethers.getContractAt("PiJFactory",piJFactoryAddress);
        piJRouter = await ethers.getContractAt("PiJRouter",piJRouterAddress);
        console.log("owner.address is:",owner.address);
        console.log("account1.address is:",account1.address);
        console.log("account2.address is:",account2.address);
        console.log("account3.address is:",account3.address);
        console.log("account4.address is:",account4.address);

        console.log("jWERC20 address is:",jWERC20.address);
        console.log("piJFactory address is:",piJFactory.address);
        console.log("piJRouter address is:",piJRouter.address);

        jw2pijsPairAddress = await piJFactory.getPair(jWERC20.address,wpijs.address);
        console.log("jw/wpijs pair address:",jw2pijsPairAddress);
        jw2pijsPair = await ethers.getContractAt("PiJPair",jw2pijsPairAddress);
    });

    it("removeLiquidity",async () => {
        const reserves = await jw2pijsPair.getReserves();
        console.log("Before removeLiquidity  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
        console.log("Before removeLiquidity  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
        console.log("Before removeLiquidity eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("Before removeLiquidity JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("Before removeLiquidity LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );

        const tx0 = await jw2pijsPair.connect(owner).approve(piJRouter.address, await jw2pijsPair.balanceOf(owner.address));
        await tx0.wait();

        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟

        const tx = await piJRouter.connect(owner).removeLiquidityETH(
            jwAddress,
            await jw2pijsPair.balanceOf(owner.address),
            0,
            0,
            owner.address,
            deadline,
            {
                gasLimit: 6721975 
            }
        );
        const receipt = await tx.wait();
        const reservesAfter = await jw2pijsPair.getReserves();
        console.log("After removeLiquidity  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reservesAfter[0]));
        console.log("After removeLiquidity  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reservesAfter[1]));
        console.log("After removeLiquidity eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("After removeLiquidity JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("After removeLiquidity LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );
    });

    it("addLiquidity",async () => {
        const reserves = await jw2pijsPair.getReserves();
        console.log("Before addLiquidity  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
        console.log("Before addLiquidity  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
        console.log("Before addLiquidity eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("Before addLiquidity JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("Before addLiquidity LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );

        const tx0 = await jWERC20.connect(owner).approve(piJRouter.address, ethers.utils.parseEther("1000"));
        await tx0.wait();

        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        const tokenAmount = ethers.utils.parseEther("100");
        const ethAmount = ethers.utils.parseEther("10");
        const amountTokenMin = tokenAmount.mul(90).div(100); // 10% 滑点
        const amountETHMin = ethAmount.mul(90).div(100);    // 10% 滑点
         const tx = await piJRouter.connect(owner).addLiquidityETH(
            jWERC20.address,
            tokenAmount,
            amountTokenMin,
            amountETHMin,
            owner.address,
            deadline,
            {
                value: ethAmount,
                gasLimit: 6721975  // 先尝试标准gas limit
            }
        );
        const receipt = await tx.wait();
        const reservesAfter = await jw2pijsPair.getReserves();
        console.log("After addLiquidity  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reservesAfter[0]));
        console.log("After addLiquidity  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reservesAfter[1]));
        console.log("After addLiquidity eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("After addLiquidity JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("After addLiquidity LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );
    });


    it("swap jw->pijs",async () => {
        const reserves = await jw2pijsPair.getReserves();
        console.log("Before swap  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
        console.log("Before swap  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
        console.log("Before swap eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("Before swap JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("Before swap LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        const tx0 = await jWERC20.connect(owner).approve(piJRouter.address,ethers.utils.parseEther("100"));
        await tx0.wait();
        const path = [jwAddress,wpijsAddress];
        const tx = await piJRouter.connect(owner).swapExactTokensForETH(
            ethers.utils.parseEther("100"),
            0,
            path,
            owner.address,
            deadline,{
                 gasLimit: 6721975
            }
        );
        await tx.wait();
        const reservesAfter = await jw2pijsPair.getReserves();
        console.log("After swap  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reservesAfter[0]));
        console.log("After swap  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reservesAfter[1]));
        console.log("After swap eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("After swap JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("After swap LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );


    });
    it("swap pijs->jw",async () => {
        
        const reserves = await jw2pijsPair.getReserves();
        console.log("Before swap  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reserves[0]));
        console.log("Before swap  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reserves[1]));
        console.log("Before swap eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("Before swap JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("Before swap LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );
        const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟
        // const tx0 = await jWERC20.connect(owner).approve(piJRouter.address,ethers.utils.parseEther("100"));
        // await tx0.wait();
        const path = [wpijsAddress,jwAddress];
        const tx = await piJRouter.connect(owner).swapExactETHForTokens(
            0,
            path,
            owner.address,
            deadline,{
                value:ethers.utils.parseEther("5"),
                gasLimit: 6721975
            }
        );
        await tx.wait();
        const reservesAfter = await jw2pijsPair.getReserves();
        console.log("After swap  ==> ","Pair token0:", await jw2pijsPair.token0(), "Pair reserves - reserve0:", ethers.utils.formatEther(reservesAfter[0]));
        console.log("After swap  ==> ","Pair token1:", await jw2pijsPair.token1(),"Pair reserves - reserve1:", ethers.utils.formatEther(reservesAfter[1]));
        console.log("After swap eth balance of owner :",
            ethers.utils.formatEther(await ethers.provider.getBalance(owner.address))
        );
        console.log("After swap JW balance of owner :",
            ethers.utils.formatEther(await jWERC20.balanceOf(owner.address))
        );
        console.log("After swap LP balance of owner :",
            ethers.utils.formatEther(await jw2pijsPair.balanceOf(owner.address))
        );


    });

});

/**
 
npx hardhat test ./test/swap/swap.test.ts --network ganache --grep "removeLiquidity"

npx hardhat test ./test/swap/swap.test.ts --network ganache --grep "addLiquidity"

npx hardhat test ./test/swap/swap.test.ts --network ganache --grep "swap jw->pijs"

npx hardhat test ./test/swap/swap.test.ts --network ganache --grep "swap pijs->jw"

 */