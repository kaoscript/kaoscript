const {Helper, initFlag, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	var __ks_Date = {};
	__ks_Date.__ks_get_culture = function(that) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		return that._culture;
	};
	__ks_Date.__ks_set_culture = function(that, value) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._culture = value;
	};
	__ks_Date.__ks_func_culture_0 = function() {
		return __ks_Date.__ks_get_culture(this);
	};
	__ks_Date.__ks_func_culture_1 = function(culture) {
		__ks_Date.__ks_set_culture(this, culture);
		return this;
	};
	__ks_Date.__ks_init = function(that) {
		that._culture = "und";
		that[initFlag] = true;
	};
	__ks_Date._im_culture = function(that, ...args) {
		return __ks_Date.__ks_func_culture_rt(that, args);
	};
	__ks_Date.__ks_func_culture_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 0) {
			return __ks_Date.__ks_func_culture_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Date.__ks_func_culture_1.call(that, args[0]);
			}
		}
		if(that.culture) {
			return that.culture(...args);
		}
		throw Helper.badArgs();
	};
	const d = new Date();
	expect(__ks_Date.__ks_func_culture_0.call(d)).to.equal("und");
	expect(__ks_Date.__ks_func_culture_1.call(d, "en")).to.equal(d);
	expect(__ks_Date.__ks_func_culture_0.call(d)).to.equal("en");
};