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
};