var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
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
	Helper.newInstanceMethod({
		class: Array,
		name: "last",
		sealed: __ks_Array,
		function: function(index) {
			if(index === void 0 || index === null) {
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
		sealed: __ks_String,
		function: function(emptyLines) {
			if(emptyLines === void 0 || emptyLines === null) {
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
		sealed: __ks_String,
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
		sealed: __ks_String,
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
		sealed: __ks_String,
		function: function(base) {
			if(base === void 0 || base === null) {
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