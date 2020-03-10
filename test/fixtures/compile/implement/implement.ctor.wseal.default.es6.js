var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_cons_0 = function(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isArray(values)) {
			throw new TypeError("'values' is not of type 'Array'");
		}
		this.setFullYear(...values);
		console.log(this.getFullYear(), this.getMonth(), this.getDate());
		return this;
	};
	__ks_Date.__ks_cons_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isString(value)) {
			throw new TypeError("'value' is not of type 'String'");
		}
		var that = __ks_Date.new(value.split("-"));
		console.log(that.getFullYear(), that.getMonth(), that.getDate());
		return that;
	};
	__ks_Date.__ks_cons_2 = function(year) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(year === void 0 || year === null) {
			throw new TypeError("'year' is not nullable");
		}
		var that = __ks_Date.new(year, 1, 1);
		console.log(that.getFullYear(), that.getMonth(), that.getDate());
		return that;
	};
	__ks_Date.new = function() {
		if(arguments.length === 1) {
			if(Type.isArray(arguments[0])) {
				return __ks_Date.__ks_cons_0.apply(new Date(), arguments);
			}
			else if(Type.isString(arguments[0])) {
				return __ks_Date.__ks_cons_1(...arguments);
			}
			else {
				return __ks_Date.__ks_cons_2(...arguments);
			}
		}
		else if(arguments.length === 0) {
			return new Date();
		}
		else {
			return new Date(...arguments);
		}
	};
	const d1 = __ks_Date.new();
	const d2 = __ks_Date.new([2000, 1, 1]);
	const d3 = __ks_Date.new("2000-01-01");
	const d4 = __ks_Date.new(2000);
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};