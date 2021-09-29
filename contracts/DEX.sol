// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

contract DEX {

    // XXX TODO Add fees const

    string public name = "My AMM Dex";

    mapping(address => mapping(address => address)) public getLiquidityPool;
    address[] public allLiquidityPools;

    event LiquidityPoolCreated(address indexed addressTokenA, address indexed addressTokenB, address indexed liquidityPool, string symbol);

    constructor() {}

    function createLiquidityPool(string memory _name, string memory _symbol, address _tokenA, address _tokenB) external returns (address) {
        require(_tokenA != _tokenB, 'Invalid tokens addresses');
        require(_tokenA != address(0), 'Invalid address');
        require(_tokenB != address(0), 'Invalid address');
        require(getLiquidityPool[_tokenA][_tokenB] == address(0), 'Liquidity Pool already exists');
        require(getLiquidityPool[_tokenB][_tokenA] == address(0), 'Liquidity Pool already exists'); 
        
        address liquidityPool = address(new LiquidityPool(_name, _symbol, _tokenA, _tokenB));
        getLiquidityPool[_tokenA][_tokenB] = liquidityPool;
        getLiquidityPool[_tokenB][_tokenA] = liquidityPool;
        allLiquidityPools.push(liquidityPool);
        
        emit LiquidityPoolCreated(_tokenA, _tokenB, liquidityPool, _symbol);
        return liquidityPool;
    }
}