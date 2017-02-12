module.exports = function(Helper, Type) {
	var __ks_Object = {};
	Helper.newClassMethod({
		class: Object,
		name: "map",
		sealed: __ks_Object,
		function: function(object, iterator) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(object === void 0 || object === null) {
				throw new TypeError("'object' is not nullable");
			}
			else if(!Type.isObject(object)) {
				throw new TypeError("'object' is not of type 'Object'");
			}
			if(iterator === void 0 || iterator === null) {
				throw new TypeError("'iterator' is not nullable");
			}
			else if(!Type.isFunction(iterator)) {
				throw new TypeError("'iterator' is not of type 'Function'");
			}
			let results = [];
			for(let item in object) {
				let index = object[item];
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
					type: "Object",
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
		class: Object,
		name: "map",
		sealed: __ks_Object,
		function: function(object, iterator, condition) {
			if(arguments.length < 3) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(object === void 0 || object === null) {
				throw new TypeError("'object' is not nullable");
			}
			else if(!Type.isObject(object)) {
				throw new TypeError("'object' is not of type 'Object'");
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
			for(let item in object) {
				let index = object[item];
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
					type: "Object",
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
		Object: Object,
		__ks_Object: __ks_Object
	};
}