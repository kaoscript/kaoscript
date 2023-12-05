const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCard: value => Type.isDexObject(value, 1, 0, {suit: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(suits) {
		if(suits === void 0) {
			suits = null;
		}
		if(Type.isArray(suits)) {
			return Helper.mapArray(suits, function(suit) {
				return (() => {
					const o = new OBJ();
					o.suit = suit;
					return o;
				})();
			});
		}
		return null;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isNumber) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};