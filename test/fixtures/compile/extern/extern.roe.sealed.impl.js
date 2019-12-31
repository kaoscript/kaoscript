var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1) {
	if(Type.isValue(__ks_0)) {
		Number = __ks_0;
		__ks_Number = __ks___ks_0;
	}
	else {
		__ks_Number = {};
	}
	if(Type.isValue(__ks_1)) {
		Math = __ks_1;
		__ks_Math = __ks___ks_1;
	}
	else {
		__ks_Math = {};
	}
	__ks_Math.pi = Math.PI;
	__ks_Math.foo = function() {
		return Math.PI;
	};
	console.log("" + __ks_Math.pi);
	console.log("" + __ks_Math.foo());
	console.log(__ks_Math.pi.toString());
	console.log(__ks_Math.foo().toString());
};