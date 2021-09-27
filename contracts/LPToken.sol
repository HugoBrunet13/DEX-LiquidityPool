pragma solidity >=0.7.0 <0.9.0;


contract LPToken {
    
    // Public variables of the token
    string public name;             // Name of the token
    string public symbol;           // Symbol of the token
    uint256 public totalSupply= 0;     // Total number of issued tokens
    address public owner;           // Address of the contract's owner

    // Array with all balances
    mapping (address => uint256) public balanceOf;

    // Public event to notify about a transfer 
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // Contract creation for logging purpose
    event ContractCreation(address indexed from, string tokenName, string tokenSymbol, uint256 intialSupply);

    // This notifies clients about the amount minted
    event Mint(address indexed from, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Initializes contract with initial supply tokens and 
     * affect them to the creator of the contract address
     */
    constructor(string memory tokenName, string memory tokenSymbol) {
        owner = msg.sender;                                 // Set owner address of the contract
        name = tokenName;                                   // Set the name of the token
        symbol = tokenSymbol;                               // Set the symbol of the token 
    }

    /** 
     * Internal transfer, can be called by this contract
     * @param _sender  address of the sender of token(s)
     * @param _receiver address of the receiver of token(s)
     * @param _value number of token(s) sent
     */
    function _transfer(address _sender, address _receiver, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_receiver != address(0x0));
        // Check if the sender has enough
        require(balanceOf[_sender] >= _value);
        // Check for overflows
        require(balanceOf[_receiver] + _value >= balanceOf[_receiver]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_sender] + balanceOf[_receiver];
        // Subtract from the sender
        balanceOf[_sender] -= _value;
        // Add the same to the recipient
        balanceOf[_receiver] += _value;
        emit Transfer(_sender, _receiver, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_sender] + balanceOf[_receiver] == previousBalances);
    }

    /**
     * Send `_value` tokens to `_receiver` from your account.
     * The caller of this function will be the sender of token 
     * This function can't be use to transfer token of a an other address that the caller's address
     * @param _receiver The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _receiver, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _receiver, _value);
        return true;
    }

    /**
     * Mint tokens.
     * Create `_value` new tokens and credit them to a specified address
     * @param _receiver the address of the receiver of the new minted token
     * @param _value the amount of token to create
     */
    function _mint(address _receiver, uint256 _value) internal returns (bool success) {
        balanceOf[_receiver] += _value;            // add new tokens to the balance of the receiver
        totalSupply += _value;                     // Updates totalSupply
        emit Mint(msg.sender, _value);
        return true;
    }

    /**
     * Burn tokens.
     * Remove `_value` tokens from the system irreversibly
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Update balances of the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

}