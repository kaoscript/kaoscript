require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return ["1", "8", "F"];
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	for(let __ks_0 = 0, __ks_1 = foo.__ks_0(), __ks_2 = __ks_1.length, item; __ks_0 < __ks_2; ++__ks_0) {
		item = __ks_1[__ks_0];
		console.log(__ks_String.__ks_func_toInt_0.call(item, 16));
	}
};