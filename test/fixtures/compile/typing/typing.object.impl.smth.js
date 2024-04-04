const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_foobar_0 = function() {
	};
	__ks_Object._sm_foobar = function() {
		if(arguments.length === 0) {
			return __ks_Object.__ks_sttc_foobar_0();
		}
		throw Helper.badArgs();
	};
};