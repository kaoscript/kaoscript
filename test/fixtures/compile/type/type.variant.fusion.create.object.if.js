const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	const Card = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {suit: () => Helper.castEnum(value, "suit", CardSuit, cast)}));
	const Result = Helper.alias((value, cast) => Position.is(value) && Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, value => Card.is(value, cast)) || Card.is(value, cast) || Type.isNull(value)}));
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
				result.values = (() => {
					const a = [];
					for(let __ks_1 = 0, __ks_0 = cards.length, suit; __ks_1 < __ks_0; ++__ks_1) {
						suit = cards[__ks_1];
						a.push((() => {
							const o = new OBJ();
							o.suit = suit;
							return o;
						})());
					}
					return a;
				})();
			}
			else {
				result.values = cards;
			}
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Card.is(value) || Type.isArray(value, value => Type.isEnumInstance(value, CardSuit)) || Type.isNull(value);
		const t1 = Position.is;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};