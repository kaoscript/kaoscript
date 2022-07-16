const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(__ks_cb) {
		return __ks_cb(null, 0);
	};
	foobar.__ks_1 = function(a, __ks_cb) {
		return __ks_cb(null, 1);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		const t1 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t1(args[0]) && t0(args[1])) {
				return foobar.__ks_1.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};