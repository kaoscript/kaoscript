const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_String = {};
	__ks_String.__ks_func_lowerFirst_0 = function() {
		return Helper.concatString(this.charAt(0).toLowerCase(), this.substring(1));
	};
	__ks_String._im_lowerFirst = function(that, ...args) {
		return __ks_String.__ks_func_lowerFirst_rt(that, args);
	};
	__ks_String.__ks_func_lowerFirst_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_lowerFirst_0.call(that);
		}
		throw Helper.badArgs();
	};
	const foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String.__ks_func_lowerFirst_0.call(foo));
};