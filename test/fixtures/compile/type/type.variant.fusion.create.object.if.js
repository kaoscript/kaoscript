const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isCard: value => Type.isDexObject(value, 1, 0, {suit: value => Type.isEnumInstance(value, CardSuit)}),
		isResult: value => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, __ksType.isCard) || __ksType.isCard(value) || Type.isNull(value)})
	};
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
			if(Type.isArray(cards)) {
				result.values = Helper.mapArray(cards, function(suit) {
					return (() => {
						const o = new OBJ();
						o.suit = suit;
						return o;
					})();
				});
			}
			else {
				result.values = cards;
			}
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isCard(value) || Type.isArray(value, value => Type.isEnumInstance(value, CardSuit)) || Type.isNull(value);
		const t1 = __ksType.isPosition;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};