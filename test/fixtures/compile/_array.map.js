var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Array, __ks_Array) {
	Helper.newClassMethod({
		class: Array,
		name: "map",
		sealed: __ks_Array,
		function: function(array, iterator) {
			if(array === undefined || array === null) {
				throw new Error("Missing parameter 'array'");
			}
			else if(!Type.isArray(array)) {
				throw new Error("Invalid type for parameter 'array'");
			}
			if(iterator === undefined || iterator === null) {
				throw new Error("Missing parameter 'iterator'");
			}
			else if(!Type.isFunction(iterator)) {
				throw new Error("Invalid type for parameter 'iterator'");
			}
			let results = [];
			for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
				item = array[index];
				results.push(iterator(item, index));
			}
			return results;
		},
		signature: {
			access: 3,
			min: 2,
			max: 2,
			parameters: [
				{
					type: "Array",
					min: 1,
					max: 1
				},
				{
					type: "Function",
					min: 1,
					max: 1
				}
			]
		}
	});
	Helper.newClassMethod({
		class: Array,
		name: "map",
		sealed: __ks_Array,
		function: function(array, iterator, condition) {
			if(array === undefined || array === null) {
				throw new Error("Missing parameter 'array'");
			}
			else if(!Type.isArray(array)) {
				throw new Error("Invalid type for parameter 'array'");
			}
			if(iterator === undefined || iterator === null) {
				throw new Error("Missing parameter 'iterator'");
			}
			else if(!Type.isFunction(iterator)) {
				throw new Error("Invalid type for parameter 'iterator'");
			}
			if(condition === undefined || condition === null) {
				throw new Error("Missing parameter 'condition'");
			}
			else if(!Type.isFunction(condition)) {
				throw new Error("Invalid type for parameter 'condition'");
			}
			let results = [];
			for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
				item = array[index];
				if(condition(item, index)) {
					results.push(iterator(item, index));
				}
			}
			return results;
		},
		signature: {
			access: 3,
			min: 3,
			max: 3,
			parameters: [
				{
					type: "Array",
					min: 1,
					max: 1
				},
				{
					type: "Function",
					min: 2,
					max: 2
				}
			]
		}
	});
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
}