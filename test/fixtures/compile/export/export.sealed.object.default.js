const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_clone_0 = function() {
		return this;
	};
	__ks_Object._sm_clone = function() {
		if(arguments.length === 0) {
			return __ks_Object.__ks_sttc_clone_0();
		}
		if(Object.clone) {
			return Object.clone(...arguments);
		}
		throw Helper.badArgs();
	};
	const foobar = (() => {
		const d = new OBJ();
		d.qux = 42;
		return d;
	})();
	return {
		foobar
	};
};