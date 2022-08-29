const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_sttc_merge_0 = function(args) {
		let i = 0;
		let l = args.length;
		while(Operator.lt(i, l) && !Type.isArray(args[i])) {
			i += 1;
		}
		if(Operator.lt(i, l)) {
			const source = args[i];
			i += 1;
			while(Operator.lt(i, l)) {
				if(Type.isArray(args[i])) {
					for(let __ks_0 = 0, __ks_1 = args[i].length, value; __ks_0 < __ks_1; ++__ks_0) {
						value = args[i][__ks_0];
						source.pushUniq(value);
					}
				}
				i += 1;
			}
			return source;
		}
		else {
			return [];
		}
	};
	__ks_Array._sm_merge = function() {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_sttc_merge_0(Helper.getVarargs(arguments, 0, pts[1]));
		}
		if(Array.merge) {
			return Array.merge(...arguments);
		}
		throw Helper.badArgs();
	};
};