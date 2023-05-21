const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	function process() {
		return process.__ks_rt(this, arguments);
	};
	process.__ks_0 = function(input) {
		return input.camelize().toUpperCase();
	};
	process.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return process.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};