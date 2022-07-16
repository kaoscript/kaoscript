const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_map_0 = function(dict, iterator) {
		let results = [];
		for(let index in dict) {
			let item = dict[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Dictionary.__ks_sttc_map_1 = function(dict, iterator, condition) {
		let results = [];
		for(let index in dict) {
			let item = dict[index];
			if(condition(item, index) === true) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Dictionary._sm_map = function() {
		const t0 = Type.isDictionary;
		const t1 = Type.isFunction;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Dictionary.__ks_sttc_map_0(arguments[0], arguments[1]);
			}
		}
		if(arguments.length === 3) {
			if(t0(arguments[0]) && t1(arguments[1]) && t1(arguments[2])) {
				return __ks_Dictionary.__ks_sttc_map_1(arguments[0], arguments[1], arguments[2]);
			}
		}
		if(Dictionary.map) {
			return Dictionary.map(...arguments);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Dictionary
	};
};