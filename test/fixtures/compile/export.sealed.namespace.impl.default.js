module.exports = function() {
	var __ks_Number = {};
	var __ks_Math = {};
	__ks_Math.pi = Math.PI;
	__ks_Math.foo = function() {
		return Math.PI;
	};
	return {
		console: console,
		Number: Number,
		__ks_Number: __ks_Number,
		Math: Math,
		__ks_Math: __ks_Math
	};
}