const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(fn) {
		return fn(0, 1, 2);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(Helper.function((a, __ks_0) => {
		if(a === void 0) {
			a = null;
		}
		if(Type.isValue(a)) {
		}
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[1]) && t0(args[2])) {
				return fn.call(null, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	}));
};