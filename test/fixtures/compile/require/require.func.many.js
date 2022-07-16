require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(reverse) {
	var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	reverse.__ks_2 = function(value) {
		return -value;
	};
	reverse.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return reverse.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return reverse.__ks_2.call(that, args[0]);
			}
			if(t2(args[0])) {
				return reverse.__ks_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Number.__ks_func_mod_0.call(reverse.__ks_2(42), 16));
	console.log(__ks_String.__ks_func_toInt_0.call(reverse.__ks_1("42")));
	console.log(__ks_Array.__ks_func_last_0.call(reverse.__ks_0([1, 2, 3])));
	return {
		reverse
	};
};