const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
				o.values = (() => {
					const a = [];
					for(let __ks_1 = 0, __ks_0 = values.length, value; __ks_1 < __ks_0; ++__ks_1) {
						value = values[__ks_1];
						a.push(value * value);
					}
					return a;
				})();
			}
			return o;
		})();
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