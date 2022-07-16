require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function degree() {
		return degree.__ks_rt(this, arguments);
	};
	degree.__ks_0 = function(value) {
		return __ks_Number.__ks_func_mod_0.call(Type.isNumber(value) ? __ks_Number.__ks_func_toInt_0.call(value) : __ks_String.__ks_func_toInt_0.call(value), 360);
	};
	degree.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return degree.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};