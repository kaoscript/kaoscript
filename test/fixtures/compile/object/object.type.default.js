const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
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
		throw Helper.badArgs();
	};
	console.log(__ks_Object.__ks_sttc_size_0((() => {
		const o = new OBJ();
		o.name = "White";
		o.honorific = "miss";
		return o;
	})()));
};