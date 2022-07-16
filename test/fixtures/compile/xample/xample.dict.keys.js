require("kaoscript/register");
const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	var __ks_Dictionary = {};
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		return __ks_Array.__ks_func_last_0.call(Dictionary.keys(x));
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isDictionary;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};