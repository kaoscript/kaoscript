const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Card = Helper.alias(value => Type.isDexObject(value, 1, 0, {suit: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(suits) {
		if(suits === void 0) {
			suits = null;
		}
		if(Type.isArray(suits)) {
			return (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = suits.length, suit; __ks_1 < __ks_0; ++__ks_1) {
					suit = suits[__ks_1];
					a.push((() => {
						const o = new OBJ();
						o.suit = suit;
						return o;
					})());
				}
				return a;
			})();
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