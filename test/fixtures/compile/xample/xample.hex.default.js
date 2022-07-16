require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	function hex() {
		return hex.__ks_rt(this, arguments);
	};
	hex.__ks_0 = function(n) {
		return __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call(Float.parse(n), 0, 255));
	};
	hex.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return hex.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	console.log(hex.__ks_0(128));
};