const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	var __ks_Date = {};
	__ks_Date.__ks_func_culture_0 = function() {
		return this._culture;
	};
	__ks_Date.__ks_func_culture_1 = function(culture) {
		if(culture === void 0) {
			culture = null;
		}
		__ks_Date.__ks_set_culture(this, culture);
		return this;
	};
	__ks_Date._im_culture = function(that, ...args) {
		return __ks_Date.__ks_func_culture_rt(that, args);
	};
	__ks_Date.__ks_func_culture_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
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
	return {
		Date,
		__ks_Date
	};
};