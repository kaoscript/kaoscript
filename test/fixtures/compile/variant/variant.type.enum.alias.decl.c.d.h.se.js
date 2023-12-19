const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCard: (value, cast, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
			if(cast) {
				if((variant = CardSuit(variant)) === null) {
					return false;
				}
				value["suit"] = variant;
			}
			else if(!Type.isEnumInstance(variant, CardSuit)) {
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
};