require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {__ks_Array, __ks_Object} = require("./.generics.extern.system.default.export.ks.j5k8r9.ksb")();
	__ks_Object.__ks_sttc_length_0 = function(object) {
		return Object.keys(object).length;
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
};