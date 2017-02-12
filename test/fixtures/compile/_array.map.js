var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Array, __ks_Array) {
	Helper.newClassMethod({
		class: Array,
		name: "map",
		sealed: __ks_Array,
		function: function(array, iterator) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(array === void 0 || array === null) {
				throw new TypeError("'array' is not nullable");
			}
			else if(!Type.isArray(array)) {
				throw new TypeError("'array' is not of type 'Array'");
			}
			if(iterator === void 0 || iterator === null) {
				throw new TypeError("'iterator' is not nullable");
			}
			else if(!Type.isFunction(iterator)) {
				throw new TypeError("'iterator' is not of type 'Function'");
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
			if(arguments.length < 3) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(array === void 0 || array === null) {
				throw new TypeError("'array' is not nullable");
			}
			else if(!Type.isArray(array)) {
				throw new TypeError("'array' is not of type 'Array'");
			}
			if(iterator === void 0 || iterator === null) {
				throw new TypeError("'iterator' is not nullable");
			}
			else if(!Type.isFunction(iterator)) {
				throw new TypeError("'iterator' is not of type 'Function'");
			}
			if(condition === void 0 || condition === null) {
				throw new TypeError("'condition' is not nullable");
			}
			else if(!Type.isFunction(condition)) {
				throw new TypeError("'condition' is not of type 'Function'");
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