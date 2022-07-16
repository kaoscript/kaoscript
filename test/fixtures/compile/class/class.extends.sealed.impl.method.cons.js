const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_func_foobar_0 = function() {
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
			__ks_Date.__ks_func_foobar_0.call(this);
		}
		__ks_init() {
		}
	}
	const d = new Date();
	const f = new FDate();
	const x = (() => {
		return new FDate();
	})();
	__ks_Date.__ks_func_foobar_0.call(d);
	__ks_Date.__ks_func_foobar_0.call(f);
	__ks_Date.__ks_func_foobar_0.call(x);
};