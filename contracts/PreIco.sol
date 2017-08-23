pragma solidity ^0.4.4;

//TODO global 0 - correct token buyout
//TODO global 1 - access rights to functions, after ICO, pausing
//TODO global 2 - multisig
//TODO global 3 - time-bound stop


contract PreIco {

    mapping (address => uint) balances;
    uint currentTokenSupply = 2500;
    //TODO correct real price
    uint priceInWei = 1*10**18;
    bool isStopped = false;
    uint timeCreated;
    uint constant PreIcoDuration = 2592000; //30 days
	
	//Events
    event TokensBought(address buyer, uint tokens);
    event ReturnExcess(address buyer, uint excess);

    //Modifiers
    modifier isRunning() {
        if (getTime() - timeCreated > PreIcoDuration) {
            isStopped = true;
        }
        require(!isStopped);
        _;
    }

    //Functions

    function() payable {
        throw;
    }

    function PreIco() {
        timeCreated = getTime();
    }

    function getTime() public returns (uint) {
        return now;
    }

    function getCurrentTokenSupply() public returns (uint) {
        return currentTokenSupply;
    }

    function getBalance() public returns (uint balance) {
        return balances[msg.sender];
    }

    function buyTokens() isRunning payable  {
        if (msg.value == 0) {
            throw;
        }
        uint buyAmount = msg.value / priceInWei;
        if (currentTokenSupply > buyAmount) {
            balances[msg.sender] = buyAmount;
            currentTokenSupply -= buyAmount;
            TokensBought(msg.sender, buyAmount);
        }
        else {
            balances[msg.sender] += currentTokenSupply;
            currentTokenSupply = 0;
            TokensBought(msg.sender, currentTokenSupply);
            isStopped = true;
            uint weiValueReturnExcess = (buyAmount - currentTokenSupply) * priceInWei;
            msg.sender.transfer(weiValueReturnExcess);
            ReturnExcess(msg.sender, weiValueReturnExcess);

        }
    }

}
