pragma solidity >=0.7.0 <0.9.0;


contract ERC20Token {
    
    // Structure to define a new lock of token(s)
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    // Public variables of the token
    string public name;             // Name of the token
    string public symbol;           // Symbol of the token
    uint256 public totalSupply;     // Total number of issued tokens
    address public owner;           // Address of the contract's owner

    // Array with all balances
    mapping (address => uint256) public balanceOf;

    // Array with all reasons why a user's tokens have been locked
    mapping(address => bytes32[]) public lockReason;

    // Array of all addresses and their associated lock for a given reason
    mapping(address => mapping(bytes32 => lockToken)) public locked;

    // Public event to notify about a transfer 
    event Transfer(address indexed from, address indexed to, uint256 value);
    

    // Contract creation for logging purpose
    event ContractCreation(address indexed from, string tokenName, string tokenSymbol, uint256 intialSupply);

    // This notifies clients about the amount minted
    event Mint(address indexed from, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // This notifies clients about the amount locked
    event Locked(address indexed _of, bytes32 indexed _reason, uint256 _amount, uint256 _validity);

    // This notifies clients about the amount unlocked
    event Unlocked(address indexed _of, bytes32 indexed _reason, uint256 _amount);
    
    /**
     * Initializes contract with initial supply tokens and 
     * affect them to the creator of the contract address
     */
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
        totalSupply = initialSupply;                        // Set total supply value
        owner = msg.sender;                                 // Set owner address of the contract
        balanceOf[msg.sender] = totalSupply;                // Credit creator balances wit all initial tokens
        name = tokenName;                                   // Set the name of the token
        symbol = tokenSymbol;                               // Set the symbol of the token 

        emit ContractCreation(msg.sender, tokenName, tokenSymbol, initialSupply);
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
     * This method can be called only by the owner of the contract
     * @param _receiver the address of the receiver of the new minted token
     * @param _value the amount of token to create
     */
    function mint(address _receiver, uint256 _value) public returns (bool success) {
        require(msg.sender == owner, "Only owner of contract can mint token"); // Check if caller is the owner of the contract
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


    /**
     * Locks a specified amount of tokens for a given time and given reason
     * @param _reason the reason why a caller locks his token(s)
     * @param _amount the amount of token(s) to lock
     * @param _lockedTime the time in second for which the token(s) will be locked
     */
    function lock(bytes32 _reason, uint256 _amount, uint256 _lockedTime) public returns (bool success) {
        require(_amount > 0, "Invalid amount"); //check params is correct
        require(balanceOf[msg.sender] >= _amount, "Insufficient balances");   // Check if the sender has enough
        // Check if there is no already existing token locked for the given reason
        require(getLockedTokens(msg.sender, _reason) == 0, "Tokens already locked for this reason"); 

        uint256 validUntil = block.timestamp + _lockedTime; // compute time until when the lock is effective

        // If there is no existing lock for the given reason,
        // store new reason for lock
        if (locked[msg.sender][_reason].amount == 0)
            lockReason[msg.sender].push(_reason);  

        // Transfer token to the address of the instance of the contract for locking
        transfer(address(this), _amount);

        // Store new lock info
        locked[msg.sender][_reason] = lockToken(_amount, validUntil, false);

        emit Locked(msg.sender, _reason, _amount, validUntil);
        return true;
    }


    /**
     * Returns locked token info of a specified address for a
     * given reason
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     */
    function getLockedTokens(address _of, bytes32 _reason) public view returns (uint256 amount) {
        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    /**
     * Returns unlockable tokens for a specified address for a given reason
     * @param _of The address to query the the unlockable token count of
     * @param _reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address _of, bytes32 _reason) public view returns (uint256 amount) {
        // Check if validity date of lock is passed and if the tokens hasn't been already claimed
        if (locked[_of][_reason].validity <= block.timestamp && !locked[_of][_reason].claimed) 
            amount = locked[_of][_reason].amount;
    }

    /**
     * Unlocks the unlockable tokens of a given address
     * @param _of Address of user, claiming back unlockable tokens
     */
    function unlock(address _of) public returns (uint256 unlockableTokens) {
        uint256 lockedTokens; // var to store the number of unlockable tokens
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            // for each reason, get the number of unlockable tokens
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens += lockedTokens ; // compute the total amount of unlocable token 
                // update the locked var to specified that the locked token has been claimned
                locked[_of][lockReason[_of][i]].claimed = true; 
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        } 
        // Release tokens
        if (unlockableTokens > 0)
            this.transfer(_of, unlockableTokens);
    }

}