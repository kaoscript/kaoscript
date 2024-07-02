const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Result = Helper.alias(value => Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, Type.isNumber) || Type.isNumber(value) || Type.isNull(value)}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(values === void 0) {
			values = null;
		}
		return (() => {
			const o = new OBJ();
			if(Type.isValue(values)) {
				o.values = Type.isArray(values) ? values : values;
			}
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isArray(value, Type.isNumber) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};