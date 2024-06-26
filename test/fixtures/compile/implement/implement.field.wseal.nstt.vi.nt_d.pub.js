const {initFlag} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const __ks_Date = {};
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
		that.culture = "und";
		that[initFlag] = true;
	};
	const d = new Date();
	expect(__ks_Date.__ks_get_culture(d)).to.not.exist;
	return {
		__ks_Date
	};
};