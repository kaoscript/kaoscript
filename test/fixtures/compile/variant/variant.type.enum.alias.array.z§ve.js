const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
	function getBlack() {
		return getBlack.__ks_rt(this, arguments);
	};
	getBlack.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.suit = CardSuit.Spades;
			o.rank = 1;
			return o;
		})();
	};
	getBlack.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getBlack.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function getClub() {
		return getClub.__ks_rt(this, arguments);
	};
	getClub.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.suit = CardSuit.Clubs;
			o.rank = 1;
			return o;
		})();
	};
	getClub.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getClub.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const cards = [getClub.__ks_0()];
};