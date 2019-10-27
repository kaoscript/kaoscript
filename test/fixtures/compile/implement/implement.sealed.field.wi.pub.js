var initFlag = require("@kaoscript/runtime").initFlag;
module.exports = function(expect) {
	var __ks_Date = {};
	__ks_Date.__ks_init_1 = function(that) {
		that.culture = "und";
	};
	__ks_Date.__ks_get_culture = function(that) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		return that.culture;
	};
	__ks_Date.__ks_set_culture = function(that, value) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that.culture = value;
	};
	__ks_Date.__ks_init = function(that) {
		__ks_Date.__ks_init_1(that);
		that[initFlag] = true;
	};
	const d = new Date();
	expect(__ks_Date.__ks_get_culture(d)).to.equal("und");
	__ks_Date.__ks_set_culture(d, "en");
	expect(__ks_Date.__ks_get_culture(d)).to.equal("en");
	const culture = __ks_Date.__ks_get_culture(d);
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};