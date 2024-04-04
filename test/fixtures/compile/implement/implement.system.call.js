const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_length_0 = function(dict) {
		return Object.keys(dict).length;
	};
	__ks_Object._sm_length = function() {
		const t0 = Type.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_length_0(arguments[0]);
			}
		}
		throw Helper.badArgs();
	};
	function length() {
		return length.__ks_rt(this, arguments);
	};
	length.__ks_0 = function(data) {
		return __ks_Object._sm_length(data);
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