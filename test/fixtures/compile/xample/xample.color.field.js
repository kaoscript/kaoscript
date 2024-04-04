require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function setField() {
		return setField.__ks_rt(this, arguments);
	};
	setField.__ks_0 = function(value, mod, round) {
		const field = __ks_Number._im_round(__ks_Number._im_mod(Type.isNumber(value) ? __ks_Number.__ks_func_toFloat_0.call(value) : __ks_String.__ks_func_toFloat_0.call(value), mod), round);
	};
	setField.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		const t1 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
				return setField.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};