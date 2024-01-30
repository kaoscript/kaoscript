const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_length_0 = function(object) {
		return Object.keys(object).length;
	};
	__ks_Object.__ks_sttc_new_0 = function() {
		return new OBJ();
	};
	__ks_Object._sm_length = function() {
		const t0 = Type.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_length_0(arguments[0]);
			}
		}
		throw Helper.badArgs();
	};
	__ks_Object._sm_new = function() {
		if(arguments.length === 0) {
			return __ks_Object.__ks_sttc_new_0();
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Object
	};
};