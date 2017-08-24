pragma solidity ^0.4.8;

import "./MultiSig.sol";

contract PreIco is MultiSigWallet {

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
        revert();
    }

    function PreIco(address[] _owners, uint _required) payable {
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
            isStopped = true;
            balances[msg.sender] += currentTokenSupply;
            TokensBought(msg.sender, currentTokenSupply);
            uint weiValueReturnExcess = (buyAmount - currentTokenSupply) * priceInWei;
            currentTokenSupply = 0;
            msg.sender.transfer(weiValueReturnExcess);
            ReturnExcess(msg.sender, weiValueReturnExcess);

        }
    }

}
