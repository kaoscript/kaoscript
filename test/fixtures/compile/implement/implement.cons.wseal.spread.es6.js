module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_cons_1 = function() {
		return this;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return __ks_Date.__ks_cons_1.apply(new Date(), arguments);
		}
		else {
			return new Date(...arguments);
		}
	};
	function foobar(...args) {
		const d = __ks_Date.new(...args);
	}
};