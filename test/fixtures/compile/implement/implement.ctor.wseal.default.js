const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_new_0 = function(...args) {
		return __ks_Date.__ks_cons_0.call(new Date(), ...args);
	};
	__ks_Date.__ks_cons_0 = function(values) {
		this.setFullYear(...values);
		console.log(this.getFullYear(), this.getMonth(), this.getDate());
		return this;
	};
	__ks_Date.__ks_new_1 = function(...args) {
		return __ks_Date.__ks_cons_1(...args);
	};
	__ks_Date.__ks_cons_1 = function(value) {
		var that = __ks_Date.new(value.split("-"));
		console.log(that.getFullYear(), that.getMonth(), that.getDate());
		return that;
	};
	__ks_Date.__ks_new_2 = function(...args) {
		return __ks_Date.__ks_cons_2(...args);
	};
	__ks_Date.__ks_cons_2 = function(year) {
		var that = __ks_Date.new(year, 1, 1);
		console.log(that.getFullYear(), that.getMonth(), that.getDate());
		return that;
	};
	__ks_Date.new = function() {
		const t0 = Type.isArray;
		const t1 = Type.isString;
		const t2 = Type.isValue;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Date.__ks_cons_0.call(new Date(), arguments[0]);
			}
			if(t1(arguments[0])) {
				return __ks_Date.__ks_cons_1(arguments[0]);
			}
			if(t2(arguments[0])) {
				return __ks_Date.__ks_cons_2(arguments[0]);
			}
		}
		return new Date(...arguments);
	};
	const d1 = __ks_Date.new();
	const d2 = __ks_Date.__ks_new_0([2000, 1, 1]);
	const d3 = __ks_Date.__ks_new_1("2000-01-01");
	const d4 = __ks_Date.__ks_new_2(2000);
	return {
		Date,
		__ks_Date
	};
};