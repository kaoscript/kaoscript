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
		if(Type.isArray(cards)) {
			result.values = [];
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