const { expect } = require('chai');
const { ethers } = require('hardhat');




describe('ERC20 Token Contract', () => {

    beforeEach(async () => {
        TokenAContract = await ethers.getContractFactory('ERC20Token');
        TokenA = await TokenAContract.deploy("1000000", "Token A", "XTA");
        [tokenAOwner, USER1, USER2, _] = await ethers.getSigners();

    })

    describe('Deploy new ERC20 Token', () => {
        it('New contract is deployed with correct properties', async () => {
            expect(await TokenA.symbol()).to.equal("XTA")
            expect(await TokenA.name()).to.equal("Token A")
            expect(await TokenA.totalSupply()).to.equal("1000000")  
        })
    })

    
})

