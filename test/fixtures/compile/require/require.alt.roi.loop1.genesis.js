const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array, __ks_Object) {
	if(!Type.isValue(__ks_Array)) {
		__ks_Array = {};
	}
	if(!Type.isValue(__ks_Object)) {
		__ks_Object = {};
	}
	__ks_Array.__ks_sttc_clone_0 = function(value) {
		return this;
	};
	__ks_Array._sm_clone = function() {
		const t0 = Type.isArray;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Array.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Array.clone) {
			return Array.clone(...arguments);
		}
		throw Helper.badArgs();
	};
	__ks_Object.__ks_sttc_clone_0 = function(value) {
		return this;
	};
	__ks_Object._sm_clone = function() {
		const t0 = Type.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Object.clone) {
			return Object.clone(...arguments);
		}
		throw Helper.badArgs();
	};
	function clone() {
		return clone.__ks_rt(this, arguments);
	};
	clone.__ks_0 = function(value) {
		return this;
	};
	clone.__ks_1 = function(value) {
		return this;
	};
	clone.__ks_2 = function(value) {
		if(value === void 0) {
			value = null;
		}
		return value;
	};
	clone.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		const t1 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return clone.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return clone.__ks_1.call(that, args[0]);
			}
			return clone.__ks_2.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array,
		__ks_Object,
		clone
	};
};