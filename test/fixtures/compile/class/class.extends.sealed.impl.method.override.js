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
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
			__ks_Date.__ks_func_foobar_0.call(this);
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			return __ks_Date.__ks_func_foobar_rt(that, args);
		}
	}
	__ks_Date._im_foobar = function(that, ...args) {
		if(that.__ks_func_foobar_rt) {
			return that.__ks_func_foobar_rt.call(null, that, args);
		}
		return __ks_Date.__ks_func_foobar_rt(that, args);
	};
	const d = new Date();
	const f = new FDate();
	const x = (() => {
		return new FDate();
	})();
	__ks_Date.__ks_func_foobar_0.call(d);
	f.__ks_func_foobar_0();
	__ks_Date.__ks_func_foobar_0.call(x);
};