const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		return 1;
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
	foobar.__ks_0([(() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return __ks_rt.__ks_0.call(this, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = (x) => {
			return "";
		};
		return __ks_rt;
	})()]);
};