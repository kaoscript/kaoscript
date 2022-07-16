const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_clone_0 = function() {
		return this;
	};
	__ks_Dictionary._sm_clone = function() {
		if(arguments.length === 0) {
			return __ks_Dictionary.__ks_sttc_clone_0();
		}
		if(Dictionary.clone) {
			return Dictionary.clone(...arguments);
		}
		throw Helper.badArgs();
	};
	const foobar = (() => {
		const d = new Dictionary();
		d.qux = 42;
		return d;
	})();
	return {
		foobar
	};
};