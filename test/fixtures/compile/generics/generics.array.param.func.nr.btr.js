const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(functions) {
		return Helper.assert((() => {
			const a = [];
			for(let __ks_1 = 0, __ks_0 = functions.length, fn; __ks_1 < __ks_0; ++__ks_1) {
				fn = functions[__ks_1];
				a.push(fn("foobar"));
			}
			return a;
		})(), "\"String[]\"", 0, value => Type.isArray(value, Type.isString));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isFunction);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};