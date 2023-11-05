const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, {
		Clubs: 1,
		Diamonds: 2,
		Hearts: 3,
		Spades: 4
	});
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	CardSuit.__ks_eq_Alls = value => value === CardSuit.Clubs || value === CardSuit.Spades || value === CardSuit.Diamonds || value === CardSuit.Hearts;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return CardSuit.Clubs;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	if(CardSuit.__ks_eq_Blacks(foobar.__ks_0())) {
	}
};