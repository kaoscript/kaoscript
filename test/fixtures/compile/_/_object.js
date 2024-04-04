const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_map_0 = function(dict, iterator) {
		let results = [];
		for(const index in dict) {
			const item = dict[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Object.__ks_sttc_map_1 = function(dict, iterator, condition) {
		let results = [];
		for(const index in dict) {
			const item = dict[index];
			if(condition(item, index) === true) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Object._sm_map = function() {
		const t0 = Type.isObject;
		const t1 = Type.isFunction;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_map_0(arguments[0], arguments[1]);
			}
		}
		if(arguments.length === 3) {
			if(t0(arguments[0]) && t1(arguments[1]) && t1(arguments[2])) {
				return __ks_Object.__ks_sttc_map_1(arguments[0], arguments[1], arguments[2]);
			}
		}
		if(Object.map) {
			return Object.map(...arguments);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Object
	};
};