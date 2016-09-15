module.exports = function() {
	var {Class, Type} = require("@kaoscript/runtime/src/runtime.js");
	var __ks_Array = {};
	var __ks_Function = {};
	var __ks_Object = {};
	Class.newClassMethod({
		class: Array,
		name: "map",
		final: __ks_Array,
		function: function(array, iterator) {
			if(array === undefined || array === null) {
				throw new Error("Missing parameter 'array'");
			}
			if(!Type.isArray(array)) {
				throw new Error("Invalid type for parameter 'array'");
			}
			if(iterator === undefined || iterator === null) {
				throw new Error("Missing parameter 'iterator'");
			}
			if(!Type.isFunction(iterator)) {
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
	Class.newClassMethod({
		class: Array,
		name: "map",
		final: __ks_Array,
		function: function(array, iterator, condition) {
			if(array === undefined || array === null) {
				throw new Error("Missing parameter 'array'");
			}
			if(!Type.isArray(array)) {
				throw new Error("Invalid type for parameter 'array'");
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
	Class.newClassMethod({
		class: Function,
		name: "vcurry",
		final: __ks_Function,
		function: function(self, bind = null, ...args) {
			if(self === undefined || self === null) {
				throw new Error("Missing parameter 'self'");
			}
			if(!Type.isFunction(self)) {
				throw new Error("Invalid type for parameter 'self'");
			}
			return function(...additionals) {
				return self.apply(bind, args.concat(additionals));
			};
		},
		signature: {
			access: 3,
			min: 1,
			max: Infinity,
			parameters: [
				{
					type: "Function",
					min: 1,
					max: 1
				},
				{
					type: "Any",
					min: 0,
					max: Infinity
				}
			]
		}
	});
	Class.newClassMethod({
		class: Object,
		name: "map",
		final: __ks_Object,
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
	Class.newClassMethod({
		class: Object,
		name: "map",
		final: __ks_Object,
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
		Array: Array,
		__ks_Array: __ks_Array,
		Class: Class,
		Function: Function,
		__ks_Function: __ks_Function,
		Object: Object,
		__ks_Object: __ks_Object,
		Type: Type
	};
}