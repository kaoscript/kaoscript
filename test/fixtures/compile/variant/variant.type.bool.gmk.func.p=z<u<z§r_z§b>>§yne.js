const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
		if(!Type.isBoolean(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant) {
			return Event.isTrue(value, mapper);
		}
		else {
			return Event.isFalse(value);
		}
	}}));
	Event.isFalse = value => Type.isDexObject(value, 0, 0, {expecting: value => Type.isString(value) || Type.isNull(value)});
	Event.isTrue = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
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
	function fooobar() {
		return fooobar.__ks_rt(this, arguments);
	};
	fooobar.__ks_0 = function(event) {
		if(event === void 0) {
			event = null;
		}
	};
	fooobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [value => Card.is(value, 0, value => CardSuit.__ks_eq_Reds(value) || CardSuit.__ks_eq_Blacks(value))], value => value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return fooobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};