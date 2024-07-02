const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Card = Helper.alias(value => Type.isDexObject(value, 1, 0, {kind: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(cards) {
		const result = (() => {
			const o = new OBJ();
			o.kind = 0;
			return o;
		})();
		if(Type.isArray(cards, Type.isNumber)) {
			result.values = (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = cards.length, kind; __ks_1 < __ks_0; ++__ks_1) {
					kind = cards[__ks_1];
					a.push((() => {
						const o = new OBJ();
						o.kind = kind;
						return o;
					})());
				}
				return a;
			})();
		}
		else {
			result.values = cards;
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Card.is(value) || Type.isArray(value, Type.isNumber);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};