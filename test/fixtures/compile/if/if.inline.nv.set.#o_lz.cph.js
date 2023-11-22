const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCard: value => Type.isDexObject(value, 1, 0, {suit: Type.isString, rank: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(cards) {
		if(cards === void 0) {
			cards = null;
		}
		return (() => {
			const o = new OBJ();
			o.cards = Type.isValue(cards) ? Helper.mapArray(cards, function(card) {
				return card.value;
			}) : [];
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isDexObject(value, 1, 0, {value: __ksType.isCard})) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};