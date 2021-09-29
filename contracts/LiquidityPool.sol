// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "hardhat/console.sol"; //For debugging only

import './libraries/SafeMath.sol';


import "./ERC20Token.sol";
// import "./librairies/Math.sol";


contract LiquidityPool is ERC20Token {

    using SafeMath for uint;

    // Public variables of the Liquidity Pool
    address public addressTokenA; 
    address public addressTokenB; 
    address public owner; 
    uint256 public reserveTokenA;
    uint256 public reserveTokenB;
    uint32 private blockTimestampLast;
    uint256 public priceTokenA;
    uint256 public priceTokenB;
    // XXX TODO Add fees

    event Sync(uint256 reserveTokenA, uint256 reserveTokenB);

    event MintLPToken(address indexed from, uint256 amountTokenA, uint256 amountTokenB);

    constructor(
        string memory _name,
        string memory _symbol,
        address _addressTokenA,
        address _addressTokenB
    ) ERC20Token(0, _name, _symbol) {
        addressTokenA = _addressTokenA;
        addressTokenB = _addressTokenB;
        owner = msg.sender;
    }

    function addLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) public returns (bool success) {
        // XXX TODO add check to make sure ratio tokenA/tokenB is correct

        ERC20Token tokenA = ERC20Token(addressTokenA);
        require(
            tokenA.transferFrom(msg.sender, address(this), _amountTokenA),
            "Tranfer of token failed"
        );
        ERC20Token tokenB = ERC20Token(addressTokenB);
        require(
            tokenB.transferFrom(msg.sender, address(this), _amountTokenB),
            "Tranfer of token failed"
        );

        mint(msg.sender); // mint new LP tokens

        return true;
    }


    function mint(address to) internal returns (uint liquidity) {
        uint256 _balanceTokenA = ERC20Token(addressTokenA).balanceOf(address(this));
        uint256 _balanceTokenB = ERC20Token(addressTokenB).balanceOf(address(this));

        uint256 _reserveTokenA = reserveTokenA;
        uint256 _reserveTokenB = reserveTokenB;

        uint256 _amountTokenA = _balanceTokenA - _reserveTokenA;
        uint256 _amountTokenB = _balanceTokenB - _reserveTokenB;
        
        uint256 _totalSupply = totalSupply; 
        if (_totalSupply == 0) { 
            liquidity = _amountTokenA * _amountTokenB / _amountTokenB; 
        } else {
            liquidity = _amountTokenA * _amountTokenB / _amountTokenB;
        }
        require(liquidity > 0, 'Liquidity added invalid');
        _mint(to, liquidity);
        _update(_balanceTokenA, _balanceTokenB, _reserveTokenA, _reserveTokenB); 
        emit MintLPToken(msg.sender, _amountTokenA, _amountTokenB);
    }


    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    // function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // function swap(uint amountIn, address tokenIn, address tokenOut) public payable returns(bool) {} // XXX TODO
    // function removeLiquidity() {} // XXX TODO




    function _update(
        uint256 _balanceTokenA,
        uint256 _balanceTokenB,
        uint256 _reserveTokenA,
        uint256 _reserveTokenB
    ) private {
        require(_balanceTokenA >= 0 && _balanceTokenB >= 0, "Invalid balances");
        if(_reserveTokenA > 0 && _reserveTokenB > 0) {
            priceTokenA += _reserveTokenA / _reserveTokenB;
            priceTokenB += _reserveTokenB / _reserveTokenA;
        }

        reserveTokenA = _balanceTokenA;
        reserveTokenB = _balanceTokenB;

        emit Sync(reserveTokenA, reserveTokenA);
    }

    function sync() external {
        _update(
            ERC20Token(addressTokenA).balanceOf(address(this)),
            ERC20Token(addressTokenB).balanceOf(address(this)),
            reserveTokenA,
            reserveTokenB
        );
    }
}
