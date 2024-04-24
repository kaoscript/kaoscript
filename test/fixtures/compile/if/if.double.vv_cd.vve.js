const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ValueList {
		static __ks_new_0() {
			const o = Object.create(ValueList.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		getTop() {
			return this.__ks_func_getTop_rt.call(null, this, this, arguments);
		}
		__ks_func_getTop_0() {
			return "foobar";
		}
		__ks_func_getTop_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_getTop_0.call(that);
			}
			throw Helper.badArgs();
		}
		hasValues() {
			return this.__ks_func_hasValues_rt.call(null, this, this, arguments);
		}
		__ks_func_hasValues_0() {
			return true;
		}
		__ks_func_hasValues_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_hasValues_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	function loadValues() {
		return loadValues.__ks_rt(this, arguments);
	};
	loadValues.__ks_0 = function() {
		return ValueList.__ks_new_0();
	};
	loadValues.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return loadValues.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let values, value, __ks_0;
	if((Type.isValue(__ks_0 = loadValues.__ks_0()) ? (values = __ks_0, true) : false) && values.__ks_func_hasValues_0() && (Type.isValue(__ks_0 = values.__ks_func_getTop_0()) ? (value = __ks_0, true) : false)) {
		console.log(value);
	}
};