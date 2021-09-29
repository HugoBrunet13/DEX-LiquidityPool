const { expect } = require('chai');
const { ethers } = require('hardhat');




describe('Liquidity Pool Contract', () => {

    beforeEach(async () => {

        TokenAContract = await ethers.getContractFactory('ERC20Token');
        TokenA = await TokenAContract.deploy("1000000000", "USDc", "USDc");
        [tokenAOwner, USER1, USER2, _] = await ethers.getSigners();

        TokenBContract = await ethers.getContractFactory('ERC20Token');
        TokenB = await TokenBContract.deploy("1000000000", "USDt", "USDt");
        [tokenBOwner, _, _, _] = await ethers.getSigners();

        await TokenA.transfer(USER1.address, 100000) 
        await TokenB.transfer(USER1.address, 100000)
        await TokenA.transfer(USER2.address, 100000) 
        await TokenB.transfer(USER2.address, 100000)
        

        LiquidityPoolContract = await ethers.getContractFactory('LiquidityPool');
        LiquidityPool = await LiquidityPoolContract.deploy("USDc / USDt", "USDc/USDt", TokenA.address, TokenB.address);
        [liquidityPoolOwner, _, _, _] = await ethers.getSigners();

    })

    describe('Create new liquidity pool for USDc/USDt', () => {
        it('New liquidity pool is created', async () => {
            expect(await LiquidityPool.symbol()).to.equal("USDc/USDt")
            expect(await LiquidityPool.name()).to.equal("USDc / USDt")
            expect(await LiquidityPool.addressTokenA()).to.equal(TokenA.address) 
            expect(await LiquidityPool.addressTokenB()).to.equal(TokenB.address)
        })
        it('Liquidity Pool LP Tokens is created with a total supply of 0', async () => {
            expect(await LiquidityPool.totalSupply()).to.equal(0)
        })
    })

    describe('USER 1 adds liquidity to the pool: 1000 USDc, 1000 USDt', () => {
        beforeEach( async () => {
            await TokenA.connect(USER1).approve(LiquidityPool.address, 100000)
            await TokenB.connect(USER1).approve(LiquidityPool.address, 100000)

            await LiquidityPool.connect(USER1).addLiquidity(1000, 1000)
        })

        it('USDc Balance of Liquidity Pool is updated with 1000 USDc', async () => {
            expect(await TokenA.balanceOf(LiquidityPool.address)).to.equal(1000)
        })
        it('USDt Balance of Liquidity Pool is updated with 1000 USDt', async () => {
            expect(await TokenB.balanceOf(LiquidityPool.address)).to.equal(1000)
        })
        it('Liquidity Pool info are updated', async () => {
            await LiquidityPool.sync()
            expect(await LiquidityPool.reserveTokenA()).to.equal(1000)
            expect(await LiquidityPool.reserveTokenB()).to.equal(1000) 

        })
        it('1000 new LP Tokens are minted => 1000 * 1000 / 1000', async () => {
            expect(await LiquidityPool.totalSupply()).to.equal(1000)
        })
        it('LP Tokens Balance of USER 1 are updated with 1000 Tokens', async () => {
            expect(await LiquidityPool.balanceOf(USER1.address)).to.equal(1000)
        })
    })


    describe('USER 2 adds liquidity to the pool: 1000 USDc, 1000 USDt', () => {
        beforeEach( async () => {
            await TokenA.connect(USER1).approve(LiquidityPool.address, 1000000)
            await TokenB.connect(USER1).approve(LiquidityPool.address, 1000000000)
            await LiquidityPool.connect(USER1).addLiquidity(1000, 1000)

            await TokenA.connect(USER2).approve(LiquidityPool.address, 1000000)
            await TokenB.connect(USER2).approve(LiquidityPool.address, 1000000000)

            await LiquidityPool.connect(USER2).addLiquidity(1000, 1000)
        })

        it('USDc Balance of Liquidity Pool is updated => 1000 + 1000 = 2000 USDc', async () => {
            expect(await TokenA.balanceOf(LiquidityPool.address)).to.equal(2000)
        })
        it('USDt Balance of Liquidity Pool is updated => 1000 + 1000 = 2000 USDt', async () => {
            expect(await TokenB.balanceOf(LiquidityPool.address)).to.equal(2000)
        })
        it('Liquidity Pool info are updated', async () => {
            await LiquidityPool.sync()
            expect(await LiquidityPool.reserveTokenA()).to.equal(2000)
            expect(await LiquidityPool.reserveTokenB()).to.equal(2000) 

        })
        it('2000 new LP Tokens are minted', async () => {
            expect(await LiquidityPool.totalSupply()).to.equal(2000)
        })
        it('LP Tokens Balance of USER 2 are updated with 1000 Tokens', async () => {
            expect(await LiquidityPool.balanceOf(USER2.address)).to.equal(1000)
        })
        it('USER 2 owns 50% of the pool', async () => {
            user2LpTokens = await LiquidityPool.balanceOf(USER2.address)
            totSupplyLpTokens = await LiquidityPool.totalSupply()
            expect(user2LpTokens/totSupplyLpTokens).to.equal(0.5)
        })
    })


    describe('TODO SWAP  - USER 1 SWAP 100 USDc ', () => {
        beforeEach( async () => {
            // await TokenA.connect(USER1).approve(LiquidityPool.address, 1000000)
            // await TokenB.connect(USER1).approve(LiquidityPool.address, 1000000000)
            // await LiquidityPool.connect(USER1).addLiquidity(1000, 1000)
        })

        it('TODO: USER 1 expect to see his USDc balance reduce with 100 USDc', async () => {
            expect(0).to.equal(1)
        })
        it('TODO: USER 1 expect to see his USDt balance increased with XXX USDt', async () => {
            expect(0).to.equal(1)
        })
        it('TODO: Reserve of Liquidity pool must be updated with +100.3 USDc and -XXX USDt', async () => {
            expect(0).to.equal(1)
        })
    })


    describe('TODO USER2 remove liquidity and collect fees', () => {
        beforeEach( async () => {
            // await TokenA.connect(USER1).approve(LiquidityPool.address, 1000000)
            // await TokenB.connect(USER1).approve(LiquidityPool.address, 1000000000)
            // await LiquidityPool.connect(USER1).addLiquidity(1000, 1000)
        })

        it('TODO: USER 2 expect to see his USDc balance credited based on his share of LP tokens', async () => {
            expect(0).to.equal(1)
        })
        it('TODO: USER 2 expect to see his USDt balance credited based on his share of LP tokens', async () => {
            expect(0).to.equal(1)
        })
        it('TODO: USER 2 LP tokens must be burned', async () => {
            expect(0).to.equal(1)
        })
    })    
})

