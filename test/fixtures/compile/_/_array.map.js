const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array) {
	__ks_Array.__ks_sttc_map_0 = function(array, iterator) {
		let results = [];
		for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
			item = array[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Array.__ks_sttc_map_1 = function(array, iterator, condition) {
		let results = [];
		for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
			item = array[index];
			if(condition(item, index) === true) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Array._sm_map = function() {
		const t0 = Type.isArray;
		const t1 = Type.isFunction;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Array.__ks_sttc_map_0(arguments[0], arguments[1]);
			}
		}
		if(arguments.length === 3) {
			if(t0(arguments[0]) && t1(arguments[1]) && t1(arguments[2])) {
				return __ks_Array.__ks_sttc_map_1(arguments[0], arguments[1], arguments[2]);
			}
		}
		if(Array.map) {
			return Array.map(...arguments);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};