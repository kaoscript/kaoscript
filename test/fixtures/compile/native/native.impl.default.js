const {Helper, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_lowerFirst_0 = function() {
		return Operator.addOrConcat(this.charAt(0).toLowerCase(), this.substring(1));
	};
	__ks_String._im_lowerFirst = function(that, ...args) {
		return __ks_String.__ks_func_lowerFirst_rt(that, args);
	};
	__ks_String.__ks_func_lowerFirst_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_lowerFirst_0.call(that);
		}
		if(that.lowerFirst) {
			return that.lowerFirst(...args);
		}
		throw Helper.badArgs();
	};
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String.__ks_func_lowerFirst_0.call(foo));
};