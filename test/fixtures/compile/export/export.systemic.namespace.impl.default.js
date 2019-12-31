module.exports = function() {
	var __ks_Number = {};
	var __ks_Math = {};
	__ks_Math.pi = Math.PI;
	__ks_Math.foo = function() {
		return Math.PI;
	};
	return {
		__ks_Number: __ks_Number,
		__ks_Math: __ks_Math
	};
};