pragma solidity ^0.4.8;

//TODO revert token buy

contract PreIco {

    mapping (address => uint) balances;
    uint currentTokenSupply = 2500;
    //TODO correct real tokenPrice
    uint tokenPrice = 1 ether;
    bool isStopped = false;
    uint timeCreated;
    uint preIcoDuration = 30 days;
    address refundeeExcess;
    uint refundAmountExcess;
    address wallet;
    address admin;

    //Events
    event TokensBought(address buyer, uint tokens);
    event Refund(address buyer, uint excess);

    //Modifiers
    modifier isRunning() {
        require(!isStopped);
        _;
    }

    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }

    //Functions

    //function PreIco(address _wallet) payable {
    function PreIco() payable {
        timeCreated = now;
        wallet = 0x6187F5AdEeDc56EA634001F14F52B0020a7bbAbd;
        admin = msg.sender;
    }

    //TODO why doesn't work without tuple identifier
    function inTime() returns (bool) {
        uint delta = now - timeCreated;
        return delta < preIcoDuration;
    }

    function buyTokens() isRunning payable  {
        require(msg.value > 0);

        if (!inTime()) {
            isStopped = true;
            return;
        }

        uint buyAmount = msg.value * tokenPrice;

        if (currentTokenSupply > buyAmount) {
            wallet.transfer(msg.value);
            balances[msg.sender] = buyAmount;
            currentTokenSupply -= buyAmount;
            TokensBought(msg.sender, buyAmount);
        }
        else {
            isStopped = true;
            balances[msg.sender] += currentTokenSupply;
            TokensBought(msg.sender, currentTokenSupply);
            refundAmountExcess = (buyAmount - currentTokenSupply) * tokenPrice;
            currentTokenSupply = 0;
        }
    }

    function refund(address refundee) {
        uint amount = balances[refundee] * tokenPrice;
        refundee.transfer(amount);
        balances[refundee] = 0;
        Refund(msg.sender, amount);
    }

    function stop() isAdmin {
        isStopped = true;
    }

    function run() isAdmin {
        isStopped = false;
    }

}
