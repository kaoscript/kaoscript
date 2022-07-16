const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_func_foobar_0 = function() {
		return 0;
	};
	__ks_Date._im_foobar = function(that, ...args) {
		return __ks_Date.__ks_func_foobar_rt(that, args);
	};
	__ks_Date.__ks_func_foobar_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_foobar_0.call(that);
		}
		if(that.foobar) {
			return that.foobar(...args);
		}
		throw Helper.badArgs();
	};
	class FDate extends Date {
		constructor() {
			super();
			this.constructor.prototype.__ks_init();
			__ks_Date.__ks_func_foobar_0.call(super);
		}
		__ks_init() {
		}
	}
};