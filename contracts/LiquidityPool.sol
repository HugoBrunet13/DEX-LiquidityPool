pragma solidity ^0.8.0;
import "hardhat/console.sol"; //For debugging only


import "./ERC20Token.sol";
import "./LPToken.sol";
import "./librairies/Math.sol";


contract LiquidityPool is LPToken {

    // uint public constant MINIMUM_LIQUIDITY = 10**3;

    // Public variables of the Liquidity Pool
    address public addressTokenA; // Address of the contract of Token A
    address public addressTokenB; // Address of the contract of Token B
    address public dex; // address of the owner of liquidity pool
    uint256 public reserveTokenA;
    uint256 public reserveTokenB;
    uint32 private blockTimestampLast;
    uint256 public priceTokenA;
    uint256 public priceTokenB;

    event Sync(uint256 reserveTokenA, uint256 reserveTokenB);

    event MintLPToken(address indexed from, uint256 amountTokenA, uint256 amountTokenB);

    /**
     * Initializes contract with initial supply tokens and
     * affect them to the creator of the contract address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _addressTokenA,
        address _addressTokenB
    ) LPToken(_name, _symbol) {
        addressTokenA = _addressTokenA;
        addressTokenB = _addressTokenB;
        dex = msg.sender;
    }

    function addLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) public returns (bool success) {
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
        // require( reserveTokenA <= _balanceTokenA, "TEST");
        // require( reserveTokenB <= _balanceTokenB, "TEST2");
        uint256 _amountTokenA = _balanceTokenA - reserveTokenA;
        uint256 _amountTokenB = _balanceTokenB - reserveTokenB;
        // bool feeOn = _mintFee(_reserve0, _reserve1);
        
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) { //First time someone provide liquidity
            liquidity = Math.sqrt(_amountTokenA * _amountTokenB) ;//- MINIMUM_LIQUIDITY; // XXX TODO Why?
           //_mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens  // XXX TODO Why?
        } else {
            liquidity = Math.min(_amountTokenA ** _totalSupply / reserveTokenA, _amountTokenB ** _totalSupply / reserveTokenA); // TODO optimize gas
        }
        require(liquidity > 0, 'LPToken: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(_balanceTokenA, _balanceTokenB, reserveTokenA, reserveTokenB); // TODO optimise gas
        // if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit MintLPToken(msg.sender, _amountTokenA, _amountTokenB);
    }



    // function swap() {} // TODO

    function _update(
        uint256 _balanceTokenA,
        uint256 _balanceTokenB,
        uint256 _reserveTokenA,
        uint256 _reserveTokenB
    ) private {
        require(_balanceTokenA >= 0 && _balanceTokenB >= 0, "Invalid balances");

        // 
        // uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        // uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if(_reserveTokenA > 0 && _reserveTokenB > 0) {
            priceTokenA += _reserveTokenA / _reserveTokenB;
            priceTokenB += _reserveTokenB / _reserveTokenA;
        }

        reserveTokenA = _balanceTokenA;
        reserveTokenB = _balanceTokenB;

        //blockTimestampLast = blockTimestamp;
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
