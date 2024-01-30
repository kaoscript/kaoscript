const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksStd_o = {};
	__ksStd_o.__ks_sttc_length_0 = function(object) {
		return Object.keys(object).length;
	};
	__ksStd_o._sm_length = function() {
		const t0 = Type.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ksStd_o.__ks_sttc_length_0(arguments[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ksStd_o
	};
};