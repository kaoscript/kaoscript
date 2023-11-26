const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(suit) {
		if(suit === CardSuit.Clubs) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, CardSuit);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};