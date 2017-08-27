pragma solidity ^0.4.8;

contract PreIco {

    mapping (address => uint) public balances;
    uint public currentTokenSupply = 2500;
    //TODO correct real tokenPrice
    uint tokenPrice = 1 ether;
    bool public isStopped = false;
    uint timeCreated;
    uint preIcoDuration = 30 days;
    address public excessRefundee;
    uint public excessRefundeeAmount;
    address public wallet;
    address admin;

    //Events
    event TokensBought(address buyer, uint tokens);
    event Refund(address buyer, uint amount);
    event ExcessRefund(address buyer, uint excess);
    event Withdrawal(address wallet, uint amount);


    //Modifiers
    modifier isRunning() {
        //TODO find out what happens when buyers send ether to stopped ICO
        require(!isStopped);
        _;
    }

    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }

    //Functions

    function PreIco(address _wallet) payable {
        timeCreated = now;
        wallet = _wallet;
        admin = msg.sender;
    }

    function inTime() returns (bool) {
        return now - timeCreated < preIcoDuration;
    }

    function buyTokens() isRunning payable {
        require(msg.value > 0);

        if (!inTime()) {
            isStopped = true;
            return;
        }

        uint buyAmount = msg.value / tokenPrice;

        if (currentTokenSupply > buyAmount) {
            balances[msg.sender] = buyAmount;
            currentTokenSupply -= buyAmount;
            TokensBought(msg.sender, buyAmount);
        }
        else {
            isStopped = true;
            balances[msg.sender] += currentTokenSupply;
            TokensBought(msg.sender, currentTokenSupply);
            excessRefundee = msg.sender;
            excessRefundeeAmount = (buyAmount - currentTokenSupply) * tokenPrice;
            currentTokenSupply = 0;
        }
    }

    function refund(address refundee) isAdmin {
        uint amount = balances[refundee] * tokenPrice;
        refundee.transfer(amount);
        balances[refundee] = 0;
        Refund(refundee, amount);
    }

    function refundExcess() isAdmin {
        balances[excessRefundee] = 0;
        excessRefundee.transfer(excessRefundeeAmount);
        ExcessRefund(excessRefundee, excessRefundeeAmount);
    }

    function pause() isAdmin {
        isStopped = true;
    }

    function run() isAdmin {
        isStopped = false;
    }

    function withdraw() isAdmin {
        uint amount = this.balance;
        wallet.transfer(this.balance);
        Withdrawal(wallet, amount);
    }

}
