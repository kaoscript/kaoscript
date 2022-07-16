require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	function toInt() {
		return toInt.__ks_rt(this, arguments);
	};
	toInt.__ks_0 = function(n) {
		return __ks_Number.__ks_func_toInt_0.call(n);
	};
	toInt.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toInt.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		toInt
	};
};