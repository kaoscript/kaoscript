const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCard: (value, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
			if((variant = CardSuit(variant)) === null) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			return true;
		}, rank: Type.isNumber})
	};
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(person) {
		if(CardSuit.__ks_eq_Blacks(person.suit)) {
			console.log("black");
		}
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