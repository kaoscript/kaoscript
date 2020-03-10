module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_cons_0 = function() {
		this.setFullYear(2000, 1, 1);
		return this;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return __ks_Date.__ks_cons_0.apply(new Date(), arguments);
		}
		else {
			return new Date(...arguments);
		}
	};
	const d = __ks_Date.new();
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};