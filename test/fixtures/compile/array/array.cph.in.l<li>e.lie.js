const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		return (() => {
			const a = [];
			for(let __ks_1 = 0, __ks_0 = values.length, vals; __ks_1 < __ks_0; ++__ks_1) {
				vals = values[__ks_1];
				a.push(...vals);
			}
			return a;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isArray(value, Type.isNumber));
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};