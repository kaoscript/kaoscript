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
			super();
			this.constructor.prototype.__ks_init();
			__ks_Date._im_foobar(this);
		}
		__ks_init() {
		}
	}
	const d = new Date();
	const f = new FDate();
	const x = (function() {
		return new FDate();
	})();
	__ks_Date._im_foobar(d);
	__ks_Date._im_foobar(f);
	__ks_Date._im_foobar(x);
};