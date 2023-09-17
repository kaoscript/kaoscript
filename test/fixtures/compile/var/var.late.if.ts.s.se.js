const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_String = {};
	__ks_String.__ks_func_toString_0 = function() {
		return this;
	};
	__ks_String._im_toString = function(that, ...args) {
		return __ks_String.__ks_func_toString_rt(that, args);
	};
	__ks_String.__ks_func_toString_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_toString_0.call(that);
		}
		if(that.toString) {
			return that.toString(...args);
		}
		throw Helper.badArgs();
	};
	let x;
	if(true) {
		x = "foobar";
		console.log(__ks_String.__ks_func_toString_0.call(x));
	}
	else {
		x = "quxbaz";
		console.log(__ks_String.__ks_func_toString_0.call(x));
	}
	console.log(__ks_String.__ks_func_toString_0.call(x));
};