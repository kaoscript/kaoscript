require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	function blend() {
		return blend.__ks_rt(this, arguments);
	};
	blend.__ks_0 = function(x, y, percentage) {
		return ((1 - percentage) * x) + (percentage * y);
	};
	blend.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return blend.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Number.__ks_func_round_0.call(blend.__ks_0(0.8, 0.5, 0.3), 2));
};