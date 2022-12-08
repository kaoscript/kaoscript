const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_size_0 = function(item) {
		return 0;
	};
	__ks_Object._sm_size = function() {
		const t0 = Type.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_size_0(arguments[0]);
			}
		}
		if(Object.size) {
			return Object.size(...arguments);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Object.__ks_sttc_size_0((() => {
		const d = new OBJ();
		d.name = "White";
		d.honorific = "miss";
		return d;
	})()));
};