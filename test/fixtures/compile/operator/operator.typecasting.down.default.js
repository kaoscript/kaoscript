require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function lines() {
		return lines.__ks_rt(this, arguments);
	};
	lines.__ks_0 = function(value) {
		return __ks_String.__ks_func_lines_0.call(Helper.cast(value, "String", false, null, "String"));
	};
	lines.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return lines.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};