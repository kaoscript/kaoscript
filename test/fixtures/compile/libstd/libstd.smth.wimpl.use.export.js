const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_key_0 = function(object, index) {
		let i = 0;
		for(const key in object) {
			if(i === index) {
				return key;
			}
			i += 1;
		}
		return null;
	};
	__ks_Object._sm_key = function() {
		const t0 = value => Type.isDexObject(value, 1, () => true);
		const t1 = Type.isNumber;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_key_0(arguments[0], arguments[1]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Object
	};
};