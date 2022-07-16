const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_length_0 = function(dict) {
		return Dictionary.keys(dict).length;
	};
	__ks_Dictionary._sm_length = function() {
		const t0 = Type.isDictionary;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_length_0(arguments[0]);
			}
		}
		if(Dictionary.length) {
			return Dictionary.length(...arguments);
		}
		throw Helper.badArgs();
	};
	function length() {
		return length.__ks_rt(this, arguments);
	};
	length.__ks_0 = function(data) {
		return __ks_Dictionary._sm_length(data);
	};
	length.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return length.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};