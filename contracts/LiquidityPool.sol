pragma solidity ^0.8.0;
import "hardhat/console.sol"; //For debugging only



import "./ERC20Token.sol";

contract LiquidityPool {
    // Public variables of the Liquidity Pool
    string public name; // Name of the token
    string public symbol; // Symbol of the token
    address public addressTokenA; // Address of the contract of Token A
    address public addressTokenB; // Address of the contract of Token B
    address public dex; // address of the owner of liquidity pool
    uint256 public reserveTokenA;
    uint256 public reserveTokenB;
    uint32 private blockTimestampLast;
    uint256 public priceTokenA;
    uint256 public priceTokenB;

    event Sync(uint256 reserveTokenA, uint256 reserveTokenB);

    /**
     * Initializes contract with initial supply tokens and
     * affect them to the creator of the contract address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _addressTokenA,
        address _addressTokenB
    ) {
        name = _name;
        symbol = _symbol;
        addressTokenA = _addressTokenA;
        addressTokenB = _addressTokenB;
        dex = msg.sender;


        // emit ContractCreation(msg.sender, tokenName, tokenSymbol, initialSupply);
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
        return true;
    }

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
        console.log("Here");
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
