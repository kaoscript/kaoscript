const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isCard: (value, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
			if((variant = CardSuit(variant)) === null) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			return true;
		}}),
		isResult: value => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, __ksType.isCard) || __ksType.isCard(value) || Type.isNull(value)}),
		isEvent: (value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return __ksType.isEvent.__1(value, mapper);
			}
			else {
				return __ksType.isEvent.__0(value);
			}
		}})
	};
	__ksType.isEvent.__0 = Type.isObject;
	__ksType.isEvent.__1 = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0], line: Type.isNumber, column: Type.isNumber});
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(cards, {line, column}) {
		if(cards === void 0) {
			cards = null;
		}
		const result = (() => {
			const o = new OBJ();
			o.line = line;
			o.column = column;
			return o;
		})();
		if(Type.isValue(cards)) {
			if(Type.isArray(cards.value)) {
				result.values = Helper.mapArray(cards.value, function(suit) {
					return (() => {
						const o = new OBJ();
						o.suit = suit;
						return o;
					})();
				});
			}
			else {
				result.values = cards.value;
			}
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [value => Type.isArray(value, value => Type.isEnumInstance(value, CardSuit)) || __ksType.isCard(value) || Type.isNull(value)], value => value) || Type.isNull(value);
		const t1 = __ksType.isPosition;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};