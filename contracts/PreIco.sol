pragma solidity ^0.4.11;

contract PreIco {

    mapping (address => uint) public balances;
    uint constant decimals = 1e18;
    uint public currentTokenSupply = 2500 * decimals;
    uint constant minimalAmount = decimals * tokenPrice;
    //TODO correct real tokenPrice
    uint constant tokenPrice = 1;
    bool public isPaused = false;
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
    event Withdrawal(address withdrawalAddress, uint amount);


    //Modifiers
    modifier isRunning() {
        //TODO find out what happens when buyers send ether to stopped ICO
        require(now < timeCreated + preIcoDuration &&
                currentTokenSupply > 0 &&
                !isPaused);
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

    function buyTokens() isRunning payable {
        require(msg.value >= minimalAmount);

        uint buyAmount = msg.value * tokenPrice;

        if (currentTokenSupply > buyAmount) {
            balances[msg.sender] = buyAmount;
            currentTokenSupply -= buyAmount;
            TokensBought(msg.sender, buyAmount);
        }
        else {
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
        isPaused = true;
    }

    function run() isAdmin {
        isPaused = false;
    }

    function withdraw() isAdmin {
        uint amount = this.balance;
        wallet.transfer(this.balance);
        Withdrawal(wallet, amount);
    }

}
