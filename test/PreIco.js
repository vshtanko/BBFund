var PreIco= artifacts.require("./PreIco.sol");
var accounts = web3.eth.accounts;

contract("PreIco test", function(accounts) {


	it("should have a starting supply of 2500", function() {
		var ico;
		return PreIco.deployed().then(function (instance) {
			ico = instance;
			return ico.getCurrentTokenSupply.call(accounts[0]);
        }).then(function(supply) {
            assert.equal(supply.valueOf(), 2500, "Supply isn't 2500!");
        });
        });

        it("should have a supply after buy for 1 ether of 2499", function() {
            var ico;
            return PreIco.deployed().then(function (instance) {
                ico = instance;
            return ico.buyTokens(
            {from:accounts[1], to:ico.address, value: web3.toWei(1, "ether")})
        }).then(function(afterSending) {
            return ico.getCurrentTokenSupply.call();
        }).then(function(supply) {
            assert.equal(supply.valueOf(), 2499, "Supply after buy isn't 2499!");
            return ico.getBalance.call({from: accounts[1]});
        }).then(function(buyer1Balance) {
                    assert.equal(buyer1Balance.valueOf(), 1, "Amount after buy is not 1!");
        });
    });

	it("should have correct buy amount if buys more than supply", function() {
    		var ico;
    		return PreIco.deployed().then(function (instance) {
    			ico = instance;
    		return ico.getCurrentTokenSupply.call(accounts[0]);
    	}).then(function(preBuyBalance) {
    	    return ico.getCurrentTokenSupply.call();
    	}).then(function(preBuyBalance) {
    	    assert.equal(preBuyBalance.valueOf(), 2499, "Supply after buy isn't 2000!");
    		return ico.buyTokens(
    		{from:accounts[2], to:ico.address, value: web3.toWei(3000, "ether")})
    	}).then(function(afterSending) {
    		return ico.getCurrentTokenSupply.call();
    	}).then(function(supply) {
    	    assert.equal(supply.valueOf(), 0, "Supply after buy isn't 0!");
    	    return ico.getBalance.call({from: accounts[2]});
        }).then(function(buyer1Balance) {
            assert.equal(buyer1Balance.valueOf(), 2499, "Amount after buy is not 2500!");
            return web3.eth.getBalance(accounts[2]);
        }).then(function(balanceAfter) {
            assert.isBelow((7501*10**18 - balanceAfter.valueOf())/10**15, 500, "Balance after refund is wrong! (up)")
            assert.isBelow((balanceAfter.valueOf() - 7501*10**18)/10**15, 500, "Balance after refund is wrong! (down)")
    	});
    });

});

