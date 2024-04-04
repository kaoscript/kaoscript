const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_func_setDate_1 = function(value) {
		this.setDate(value);
		return this;
	};
	__ks_Date._im_setDate = function(that, ...args) {
		return __ks_Date.__ks_func_setDate_rt(that, args);
	};
	__ks_Date.__ks_func_setDate_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Date.__ks_func_setDate_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(d) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Date);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const d = new Date();
	foobar.__ks_0(__ks_Date.__ks_func_setDate_1.call(d, 1));
	return {
		__ks_Date
	};
};