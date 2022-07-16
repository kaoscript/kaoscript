const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_clone_0 = function(dict) {
		let clone = new Dictionary();
		return clone;
	};
	__ks_Dictionary._sm_clone = function() {
		const t0 = Type.isDictionary;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Dictionary.clone) {
			return Dictionary.clone(...arguments);
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value === void 0) {
			value = null;
		}
		return __ks_Dictionary._sm_clone(value);
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};