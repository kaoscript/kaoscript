const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCard: (value, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
			if(!Type.isEnumInstance(variant, CardSuit)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			return true;
		}, rank: Type.isNumber})
	};
	const CardSuit = Helper.enum(Number, {
		Clubs: 1,
		Diamonds: 2,
		Hearts: 3,
		Spades: 4
	});
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(card) {
		let __ks_0;
		if(CardSuit.__ks_eq_Blacks(card.suit)) {
			__ks_0 = "black";
		}
		else if(CardSuit.__ks_eq_Reds(card.suit)) {
			__ks_0 = "red";
		}
		return __ks_0;
	};
	greeting.__ks_rt = function(that, args) {
		const t0 = __ksType.isCard;
		if(args.length === 1) {
			if(t0(args[0])) {
				return greeting.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};