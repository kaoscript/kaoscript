var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_func_foobar_0 = function() {
	};
	__ks_Date._im_foobar = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_foobar_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	class FDate extends Date {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
		__ks_func_foobar_0() {
			__ks_Date._im_foobar(this);
		}
		foobar() {
			if(arguments.length === 0) {
				return FDate.prototype.__ks_func_foobar_0.apply(this);
			}
			return Date.prototype.foobar.apply(this, arguments);
		}
	}
	__ks_Date._im_0_foobar = __ks_Date._im_foobar;
	__ks_Date._im_foobar = function(that) {
		if(Type.isClassInstance(that, FDate)) {
			return that.foobar.apply(that, Array.prototype.slice.call(arguments, 1, arguments.length));
		}
		else {
			return __ks_Date._im_0_foobar.apply(null, arguments);
		}
	};
	const d = new Date();
	const f = new FDate();
	const x = (() => {
		return new FDate();
	})();
	__ks_Date._im_foobar(d);
	f.foobar();
	__ks_Date._im_foobar(x);
};