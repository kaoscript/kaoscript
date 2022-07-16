const {Helper, Type} = require("@kaoscript/runtime");
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
		return __ks_Math.foo.__ks_rt(this, arguments);
	};
	__ks_Math.foo.__ks_0 = function() {
		return Math.PI;
	};
	__ks_Math.foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Math.foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(Helper.toString(__ks_Math.pi));
	console.log(Helper.toString(__ks_Math.foo.__ks_0()));
	console.log(__ks_Math.pi.toString());
	console.log(__ks_Math.foo.__ks_0().toString());
};