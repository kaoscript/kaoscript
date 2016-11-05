var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	Helper.newClassMethod({
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
	Helper.newClassMethod({
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
	Helper.newInstanceMethod({
		class: Array,
		name: "last",
		final: __ks_Array,
		function: function(index) {
			if(index === undefined || index === null) {
				index = 1;
			}
			return this.length ? this[this.length - index] : null;
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "lines",
		final: __ks_String,
		function: function(emptyLines) {
			if(emptyLines === undefined || emptyLines === null) {
				emptyLines = false;
			}
			if(this.length === 0) {
				return [];
			}
			else if(emptyLines) {
				return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
			}
			else {
				return this.match(/[^\r\n]+/g) || [];
			}
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	Helper.newInstanceMethod({
		class: String,
		name: "lower",
		final: __ks_String,
		method: "toLowerCase",
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	Helper.newInstanceMethod({
		class: String,
		name: "toFloat",
		final: __ks_String,
		function: function() {
			return parseFloat(this);
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	Helper.newInstanceMethod({
		class: String,
		name: "toInt",
		final: __ks_String,
		function: function(base) {
			if(base === undefined || base === null) {
				base = 10;
			}
			return parseInt(this, base);
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	return {
		Array: Array,
		__ks_Array: __ks_Array,
		String: String,
		__ks_String: __ks_String
	};
}