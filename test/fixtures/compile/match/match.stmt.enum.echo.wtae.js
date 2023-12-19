const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(String, 0, "Clubs", "clubs", "Diamonds", "diamonds", "Hearts", "hearts", "Spades", "spades");
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(card) {
		if(card === CardSuit.Clubs) {
			console.log("clubs");
		}
		else if(card === CardSuit.Diamonds) {
			console.log("diamonds");
		}
		else {
			console.log("hearts or spades");
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};