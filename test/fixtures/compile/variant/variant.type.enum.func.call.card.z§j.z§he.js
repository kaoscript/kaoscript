const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	const Card = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
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
	}, rank: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Card.is(value, 0, CardSuit.__ks_eq_Reds);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0((() => {
		const o = new OBJ();
		o.suit = CardSuit.Hearts;
		o.rank = 1;
		return o;
	})());
};