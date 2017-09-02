var PreIco= artifacts.require("./PreIco.sol");
var accounts = web3.eth.accounts;

contract("PreIco test", function(accounts) {


	it("should have coorect buy logic", function() {
		return PreIco.deployed().then(function (instance) {
			ico = instance;
			return ico.currentTokenSupply.call(accounts[0]);
        }).then(function(supply) {
            assert.equal(supply.valueOf(), 2500*1e18, "Supply isn't 2500!");
        });
        });

        it("should have a supply after buy for 1 ether of 2499", function() {
            var ico;
            return PreIco.deployed().then(function (instance) {
                ico = instance;
            return web3.eth.sendTransaction({from: accounts[1], to: ico.address, value: web3.toWei(1, "ether")});
        }).then(function(afterSending) {
            return ico.currentTokenSupply.call();
        }).then(function(supply) {
            assert.equal(supply.valueOf(), 2499*1e18, "Supply after buy isn't 2499!");
            return ico.balances.call(accounts[1]);
        }).then(function(buyer1Balance) {
                    assert.equal(buyer1Balance.valueOf(), 1e18, "Amount after buy is not 1!");
        });
    });

	it("should have correct logic on overbuy", function() {
    		return PreIco.deployed().then(function (instance) {
    			ico = instance;
    		return ico.currentTokenSupply.call(accounts[0]);
    	}).then(function(preBuyBalance) {
    	    return ico.currentTokenSupply.call();
    	}).then(function(preBuyBalance) {
    	    assert.equal(preBuyBalance.valueOf(), 2499*1e18, "Supply after buy isn't 2499!");
    		return ico.buyTokens(
    		{from:accounts[2], to:ico.address, value: web3.toWei(3000, "ether")})
    	}).then(function(afterSending) {
    		return ico.currentTokenSupply.call();
    	}).then(function(supply) {
    	    assert.equal(supply.valueOf(), 0, "Supply after buy isn't 0!");
    	    return ico.balances.call(accounts[2]);
        }).then(function(buyer1Balance) {
            assert.equal(buyer1Balance.valueOf(), 2499*1e18, "Balance after overbuy is not correct!");
            return ico.excessRefundee.call();
        }).then(function(excessRefundee) {
            assert.equal(excessRefundee.valueOf(), accounts[2], "Wrong refundee address!");
            return ico.excessRefundeeAmount.call();
        }).then(function(excessRefundeeAmount) {
            assert.equal(excessRefundeeAmount.valueOf(), web3.toWei(3000-2499, "ether"), "Excess refund amount incorrect");
        });
    });

    it("should have correct logic on admin pause/run", function() {
            return PreIco.deployed().then(function (instance) {
                ico = instance;
            return ico.pause();
        }).then(function(_) {
            return ico.isPaused();
        }).then(function(isPaused) {
            assert.equal(isPaused.valueOf(), true, "Doesn't pause correctly");
            return ico.buyTokens(
                {from:accounts[1], to:ico.address, value: web3.toWei(1, "ether")})
        }).then(assert.fail)
            .catch(function(error) {
            return ico.run();
        }).then(function(_) {
            return ico.isPaused();
        }).then(function(isPaused) {
            assert.equal(isPaused.valueOf(), false, "Doesn't run correctly");
            return ico.pause({from: accounts[1]});
        }).then(assert.fail)
        .catch(function(error) {
            return ico.isPaused();
        }).then(function(isPaused) {
            assert.equal(isPaused.valueOf(), false, "Admin rights compromised");
        });
    });


    it("should have correct logic on refundExcess", function() {
        return PreIco.deployed().then(function (instance) {
            ico = instance;
        return ico.refundExcess({from: accounts[0]});
    }).then(function(_) {
        return web3.eth.getBalance(web3.eth.accounts[2]);
    }).then(function(balanceAfter) {
        assert.isBelow((7501*10**18 - balanceAfter.valueOf())/10**15, 500, "Balance after refund is wrong! (up)")
        assert.isBelow((balanceAfter.valueOf() - 7501*10**18)/10**15, 500, "Balance after refund is wrong! (down)")
    });
});

    it("should have correct logic on refund", function() {
            return PreIco.deployed().then(function (instance) {
                ico = instance;
            return ico.refund(accounts[1]);
        }).then(function(_) {
            return ico.balances(accounts[1]);
        }).then(function(buyer1Balance) {
           assert.equal(buyer1Balance.valueOf(), 0, "Amount after refund  is not 0!");
            return web3.eth.getBalance(web3.eth.accounts[1]);
        }).then(function(balanceAfter) {
            assert.isBelow((9999*10**18 - balanceAfter.valueOf())/10**15, 500, "Balance after refund is wrong! (up)")
            //assert.isBelow((balanceAfter.valueOf()), 500, "Balance after refund is wrong! (up)")
            assert.isBelow((balanceAfter.valueOf() - 9999*10**18)/10**15, 500, "Balance after refund is wrong! (down)")
        });
    });

    it("should have correct logic on fund transfer", function() {
            return PreIco.deployed().then(function (instance) {
                ico = instance;
            return ico.wallet.call();
        }).then(function(wallet) {
            assert.equal(wallet.valueOf(), accounts[3], "checkBalance");
            return ico.withdraw();
        }).then(function(withdraw) {
            return web3.eth.getBalance(web3.eth.accounts[3]);
        }).then(function(balanceAfter) {
            assert.isBelow((12499*10**18 - balanceAfter.valueOf())/10**15, 500, "Balance after refund is wrong! (up)")
            assert.isBelow((balanceAfter.valueOf() - 12499*10**18)/10**15, 500, "Balance after refund is wrong! (down)")
        });
    });



});

