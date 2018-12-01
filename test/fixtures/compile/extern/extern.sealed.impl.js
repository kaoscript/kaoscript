module.exports = function() {
	var __ks_Number = {};
	var __ks_Math = {};
	__ks_Math.pi = Math.PI;
	__ks_Math.foo = function() {
		return Math.PI;
	};
	console.log("" + __ks_Math.pi);
	console.log("" + __ks_Math.foo());
	console.log(__ks_Math.pi.toString());
	console.log(__ks_Math.foo().toString());
};