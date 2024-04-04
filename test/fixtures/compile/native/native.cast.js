const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_String = {};
	__ks_String.__ks_func_lower_0 = function() {
		return this.toLowerCase();
	};
	__ks_String._im_lower = function(that, ...args) {
		return __ks_String.__ks_func_lower_rt(that, args);
	};
	__ks_String.__ks_func_lower_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_lower_0.call(that);
		}
		throw Helper.badArgs();
	};
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String.__ks_func_lower_0.call(foo));
};