require("kaoscript/register");
const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./.import.roi.rr.ks.np51g.ksb")().__ks_Array;
	const m = __ks_Array.__ks_sttc_map_0(Helper.newArrayRange(1, 10, 1, true, true), (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return __ks_rt.__ks_0.call(this, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = (value, index) => {
			return Operator.multiplication(value, index);
		};
		return __ks_rt;
	})());
	return {
		__ks_Array
	};
};