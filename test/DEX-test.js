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

        DEXContract = await ethers.getContractFactory('DEX');
        DEX = await DEXContract.deploy();
        [tokenBOwner, _, _, _] = await ethers.getSigners();

    })

    describe('Create new DEX', () => {
        it('New DEX is created', async () => {
            expect(await DEX.name()).to.equal("My AMM Dex")
        })
    })

    describe('Create new Liquidity Pool', () => {
        it('New Pool for USDc/USDt is created', async () => {
            await DEX.createLiquidityPool("USDc / USDt", "USDc/USDt", TokenA.address, TokenB.address)
            addressLiquidityPool = await DEX.getLiquidityPool(TokenA.address, TokenB.address)   
            expect(addressLiquidityPool).to.equal(await DEX.allLiquidityPools(0))
        })
    })




   

    
})

