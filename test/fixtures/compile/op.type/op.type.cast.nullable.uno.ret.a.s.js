require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function lines() {
		return lines.__ks_rt(this, arguments);
	};
	lines.__ks_0 = function(value) {
		let __ks_0;
		return Type.isValue(__ks_0 = Helper.assertString(value, 1)) ? __ks_String.__ks_func_lines_0.call(__ks_0) : null;
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