const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Foobar = {};
	__ks_Foobar.__ks_new_1 = function(...args) {
		return __ks_Foobar.__ks_cons_1.call(new Foobar(), ...args);
	};
	__ks_Foobar.__ks_cons_1 = function(x) {
		__ks_Foobar.__ks_func_foobar_0.call(this);
		return this;
	};
	__ks_Foobar.__ks_func_foobar_0 = function() {
	};
	__ks_Foobar.new = function() {
		const t0 = Type.isNumber;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Foobar.__ks_cons_1.call(new Foobar(), arguments[0]);
			}
		}
		throw Helper.badArgs();
	};
	__ks_Foobar._im_foobar = function(that, ...args) {
		return __ks_Foobar.__ks_func_foobar_rt(that, args);
	};
	__ks_Foobar.__ks_func_foobar_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Foobar.__ks_func_foobar_0.call(that);
		}
		throw Helper.badArgs();
	};
};