const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_clone_0 = function() {
		return this;
	};
	__ks_Object._sm_clone = function() {
		if(arguments.length === 0) {
			return __ks_Object.__ks_sttc_clone_0();
		}
		throw Helper.badArgs();
	};
	const foobar = (() => {
		const o = new OBJ();
		o.qux = 42;
		return o;
	})();
	return {
		foobar
	};
};