require("kaoscript/register");
const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./.import.roi.rr.ks.np51g.ksb")().__ks_Array;
	const m = __ks_Array.__ks_sttc_map_0(Helper.newArrayRange(1, 10, 1, true, true), Helper.function((value, index) => {
		return Operator.multiplication(value, index);
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}));
	return {
		__ks_Array
	};
};