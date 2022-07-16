module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_new_0 = function() {
		return __ks_Date.__ks_cons_0.call(new Date(), );
	};
	__ks_Date.__ks_cons_0 = function() {
		this.setFullYear(2000, 1, 1);
		return this;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return __ks_Date.__ks_cons_0.call(new Date());
		}
		return new Date(...arguments);
	};
	const d = __ks_Date.__ks_new_0();
	return {
		Date,
		__ks_Date
	};
};