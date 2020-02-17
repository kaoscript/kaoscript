module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_func_foobar_0 = function() {
		return 0;
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
};