require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../export/.export.func.type.ks.j5k8r9.ksb")().__ks_Number;
	__ks_Number.__ks_func_repeat_0.call(4, Helper.function((index, max) => {
		const i = index + max + 1;
	}, (fn, ...args) => {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}));
};