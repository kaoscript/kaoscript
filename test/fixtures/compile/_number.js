var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "limit",
		sealed: __ks_Number,
		function: function(min, max) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(min === void 0 || min === null) {
				throw new TypeError("'min' is not nullable");
			}
			if(max === void 0 || max === null) {
				throw new TypeError("'max' is not nullable");
			}
			return isNaN(this) ? min : Math.min(max, Math.max(min, this));
		},
		signature: {
			access: 3,
			min: 2,
			max: 2,
			parameters: [
				{
					type: "Any",
					min: 2,
					max: 2
				}
			]
		}
	});
	Helper.newInstanceMethod({
		class: Number,
		name: "mod",
		sealed: __ks_Number,
		function: function(max) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(max === void 0 || max === null) {
				throw new TypeError("'max' is not nullable");
			}
			if(isNaN(this)) {
				return 0;
			}
			else {
				let n = this % max;
				if(n < 0) {
					return n + max;
				}
				else {
					return n;
				}
			}
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 1
				}
			]
		}
	});
	Helper.newInstanceMethod({
		class: Number,
		name: "round",
		sealed: __ks_Number,
		function: function(precision) {
			if(precision === void 0 || precision === null) {
				precision = 0;
			}
			precision = Math.pow(10, precision).toFixed(0);
			return Math.round(this * precision) / precision;
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
		class: Number,
		name: "toFloat",
		sealed: __ks_Number,
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
		class: Number,
		name: "toInt",
		sealed: __ks_Number,
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
		Number: Number,
		__ks_Number: __ks_Number
	};
}