pragma solidity ^0.4.11;

contract PreIco {


    uint constant PREICO_DURATION = 90 days;
    //TODO correct real TOKEN_PRICE
    uint constant TOKEN_PRICE = 1;
    uint constant DECIMALS = 10**18;
    uint constant MINIMAL_AMOUNT = DECIMALS * TOKEN_PRICE;

    uint timeCreated;
    bool public isPaused = false;

    mapping (address => uint) public balances;
    uint public currentTokenSupply = 2500 * DECIMALS;

    address public wallet;
    address admin;

    address public excessRefundee;
    uint public excessRefundeeAmount;

    //Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address buyer, uint amount);
    event ExcessRefund(address buyer, uint excess);
    event Withdrawal(address withdrawalAddress, uint amount);


    //Modifiers
    modifier isRunning() {
        //TODO find out what happens when buyers send ether to stopped ICO
        require(now < timeCreated + PREICO_DURATION &&
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

    function () payable {
        buyTokens();
    }

    function buyTokens() isRunning payable {
        require(msg.value >= MINIMAL_AMOUNT);

        uint buyAmount = msg.value * TOKEN_PRICE;

        if (currentTokenSupply > buyAmount) {
            balances[msg.sender] += buyAmount;
            currentTokenSupply -= buyAmount;
            Transfer(address(this), msg.sender, buyAmount);
        }
        else {
            balances[msg.sender] += currentTokenSupply;
            Transfer(address(this), msg.sender, buyAmount);
            excessRefundee = msg.sender;
            excessRefundeeAmount = (buyAmount - currentTokenSupply) / TOKEN_PRICE;
            currentTokenSupply = 0;
        }
    }

    function refund(address refundee) isAdmin {
        uint amount = balances[refundee] / TOKEN_PRICE;
        currentTokenSupply += balances[refundee];
        refundee.transfer(amount);
        balances[refundee] = 0;
        Refund(refundee, amount);
    }

    function refundExcess() isAdmin {
        excessRefundee.transfer(excessRefundeeAmount);
        ExcessRefund(excessRefundee, excessRefundeeAmount);
        excessRefundeeAmount = 0;
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
