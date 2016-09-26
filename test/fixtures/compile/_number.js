var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "limit",
		final: __ks_Number,
		function: function(min, max) {
			if(min === undefined || min === null) {
				throw new Error("Missing parameter 'min'");
			}
			if(max === undefined || max === null) {
				throw new Error("Missing parameter 'max'");
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
		final: __ks_Number,
		function: function(max) {
			if(max === undefined || max === null) {
				throw new Error("Missing parameter 'max'");
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
		final: __ks_Number,
		function: function(precision) {
			if(precision === undefined || precision === null) {
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
		final: __ks_Number,
		function: function() {
			return parseFloat(this);
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: [
			]
		}
	});
	Helper.newInstanceMethod({
		class: Number,
		name: "toInt",
		final: __ks_Number,
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
		Number: Number,
		__ks_Number: __ks_Number
	};
}