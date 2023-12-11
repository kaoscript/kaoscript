const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_delete_0 = function(object, property) {
		Helper.delete(object, property);
	};
	__ks_Object._sm_delete = function() {
		const t0 = Type.isObject;
		const t1 = Type.isValue;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_delete_0(arguments[0], arguments[1]);
			}
		}
		if(Object.delete) {
			return Object.delete(...arguments);
		}
		throw Helper.badArgs();
	};
};