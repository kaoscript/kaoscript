module.exports = function(Helper, Type) {
	var __ks_Object = {};
	Helper.newClassMethod({
		class: Object,
		name: "map",
		sealed: __ks_Object,
		function: function(object, iterator) {
			if(object === undefined || object === null) {
				throw new Error("Missing parameter 'object'");
			}
			if(!Type.isObject(object)) {
				throw new Error("Invalid type for parameter 'object'");
			}
			if(iterator === undefined || iterator === null) {
				throw new Error("Missing parameter 'iterator'");
			}
			if(!Type.isFunction(iterator)) {
				throw new Error("Invalid type for parameter 'iterator'");
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
			if(object === undefined || object === null) {
				throw new Error("Missing parameter 'object'");
			}
			if(!Type.isObject(object)) {
				throw new Error("Invalid type for parameter 'object'");
			}
			if(iterator === undefined || iterator === null) {
				throw new Error("Missing parameter 'iterator'");
			}
			if(!Type.isFunction(iterator)) {
				throw new Error("Invalid type for parameter 'iterator'");
			}
			if(condition === undefined || condition === null) {
				throw new Error("Missing parameter 'condition'");
			}
			if(!Type.isFunction(condition)) {
				throw new Error("Invalid type for parameter 'condition'");
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