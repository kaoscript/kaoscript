const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_size_0 = function(item) {
		return 0;
	};
	__ks_Dictionary._sm_size = function() {
		const t0 = Type.isDictionary;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_size_0(arguments[0]);
			}
		}
		if(Dictionary.size) {
			return Dictionary.size(...arguments);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Dictionary.__ks_sttc_size_0((() => {
		const d = new Dictionary();
		d.name = "White";
		d.honorific = "miss";
		return d;
	})()));
};