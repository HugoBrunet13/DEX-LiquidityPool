# DEX - Liquidity Pool (AMM) - INCOMPLETE

Incomplete Automated Market Market Dex. 

Missing parts:
* Make sure when LP adds liquidity, the ratio TokenA/TokenB is respected
* Add swap method for both side (SWAP TokenA and receive TokenB, Swap TokenB and receive TokenA)
* Make sure the fees are collected
* Add remove liquidity function for LP to withdraw their tokens and receive their reward

## Structure of the project
### 1. Smart contracts - `contract/` 
Smart contract are implemented with **Solidity** and require the **version 0.8.0** of the compiler. 
1. `ERC20Token.sol`   
Basic ERC20 Token contract used by Liquidity providers and trader to interact with the Dex

2. `DEX.sol`  
Decentralized market place where new liquidity pool can be created.  

3. `LiquidityPool.sol`  
Main file of the project. The liquidity pool contract represents a TokenA/TokenB liquidity pool.  
Liquidity providers can provide liquidity to the pool. They will then receive Liquidity Provider Tokens (LPTokens), which represent the share of the liquidity pool they own.   
When they withdraw the liquidity they provided, they will  be refunded with the same amount of token they deposits + the fees collected with all trades (0.3% on each trades).  
### 2. Tests - `test/`
Unit tests for `DEX.sol`, `LiquidityPool.sol` and `ERC20Token.sol` contracts. 

## How to run?
### Stack
* NodeJS (v >= 12.0.0)
* npm 
* Hardhat 
* Solidity (v0.8.0)

### Install dependencies and run tests
1. ` npm install`
2. `npx hardhat compile` (to compile contracts and generate artifacts)
3. `npx hardhat test` (to run existing unit tests)  

## Testing

Contracts have been tested using **Hardhat** framework and **Chai** library.   
To run the test, please make sure all dependencies are installed please type: `npx hardhat test`.

Bellow an overview of the result of the tests of contracts:

```
  DEX Contract
    Create new DEX
      √ New DEX is created
    Create new Liquidity Pool
      √ New Pool for USDc/USDt is created (61ms)

  ERC20 Token Contract
    Deploy new ERC20 Token
      √ New contract is deployed with correct properties

  Liquidity Pool Contract
    Create new liquidity pool for USDc/USDt
      √ New liquidity pool is created
      √ Liquidity Pool LP Tokens is created with a total supply of 0
    USER 1 adds liquidity to the pool: 1000 USDc, 1000 USDt
      √ USDc Balance of Liquidity Pool is updated with 1000 USDc
      √ USDt Balance of Liquidity Pool is updated with 1000 USDt
      √ Liquidity Pool info are updated
      √ 1000 new LP Tokens are minted => 1000 * 1000 / 1000
      √ LP Tokens Balance of USER 1 are updated with 1000 Tokens
    USER 2 adds liquidity to the pool: 1000 USDc, 1000 USDt
      √ USDc Balance of Liquidity Pool is updated => 1000 + 1000 = 2000 USDc
      √ USDt Balance of Liquidity Pool is updated => 1000 + 1000 = 2000 USDt
      √ Liquidity Pool info are updated
      √ 2000 new LP Tokens are minted
      √ LP Tokens Balance of USER 2 are updated with 1000 Tokens
      √ USER 2 owns 50% of the pool
    TODO SWAP  - USER 1 SWAP 100 USDc 
      X TODO: USER 1 expect to see his USDc balance reduce with 100 USDc
      X TODO: USER 1 expect to see his USDt balance increased with XXX USDt
      X TODO: Reserve of Liquidity pool must be updated with +100.3 USDc and -XXX USDt
    TODO USER2 remove liquidity and collect fees
      X TODO: USER 2 expect to see his USDc balance credited based on his share of LP tokens
      X TODO: USER 2 expect to see his USDt balance credited based on his share of LP tokens
      X TODO: USER 2 LP tokens must be burned


  16 passing (7s)
  6 failing
```

## Documentation:
https://www.theancientbabylonians.com/what-is-liquidity-pool-lp-in-defi/  
https://docs.uniswap.org/protocol/V2/concepts/core-concepts/pools  

