const { expect } = require('chai');
const { ethers } = require('hardhat');


describe('Liquidity Pool Contract', () => {

    beforeEach(async () => {

        TokenAContract = await ethers.getContractFactory('ERC20Token');
        TokenA = await TokenAContract.deploy("100000", "Ether", "ETH");
        [tokenAOwner, _, _, _] = await ethers.getSigners();

        TokenBContract = await ethers.getContractFactory('ERC20Token');
        TokenB = await TokenBContract.deploy("1000000000", "Tether", "USDt");
        [tokenBOwner, USER1, USER2, _] = await ethers.getSigners();
        

        LiquidityPoolContract = await ethers.getContractFactory('LiquidityPool');
        LiquidityPool = await LiquidityPoolContract.deploy("Ether / Tether", "ETH/USDt", TokenA.address, TokenB.address);
        [liquidityPoolOwner, _, _, _] = await ethers.getSigners();

    })

    describe('Create new liquidity pool ETH/USDt', () => {
        it('New liquidity pool is created', async () => {
            expect(await LiquidityPool.symbol()).to.equal("ETH/USDt")
            expect(await LiquidityPool.name()).to.equal("Ether / Tether")
            expect(await LiquidityPool.addressTokenA()).to.equal(TokenA.address) 
            expect(await LiquidityPool.addressTokenB()).to.equal(TokenB.address)
        })
    })

    describe('Add liquidity to the pool: 200 ETH, 400000 USDt', () => {
        beforeEach( async () => {
            await TokenA.approve(LiquidityPool.address, 1000000)
            await TokenB.approve(LiquidityPool.address, 1000000000)

            await LiquidityPool.addLiquidity(200, 400000)
        })

        it('ETH Balance of Liquidity Pool is updated with 200 ETH', async () => {
            expect(await TokenA.balanceOf(LiquidityPool.address)).to.equal(200)
        })
        it('USDt Balance of Liquidity Pool is updated with 400000 USDt', async () => {
            expect(await TokenB.balanceOf(LiquidityPool.address)).to.equal(400000)
        })
        it('Liquidity Pool info are updated', async () => {
            await LiquidityPool.sync()
            expect(await LiquidityPool.reserveTokenA()).to.equal(200)
            expect(await LiquidityPool.reserveTokenB()).to.equal(400000) 

        })
    
    })






   

    
})

