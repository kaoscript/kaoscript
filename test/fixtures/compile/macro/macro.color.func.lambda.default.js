module.exports = function() {
	let Space = {
		RGB: "rgb",
		SRGB: "srgb"
	};
	class Color {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	Color.registerSpace({
		name: Space.SRGB,
		"alias": [Space.RGB],
		"formatters": {
			hex: function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				return $hex(that);
			},
			srgb: function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				if(that._alpha === 1) {
					return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
				}
				else {
					return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
				}
			}
		},
		"components": {
			"red": {
				"max": 255,
				"field": "_red"
			},
			"green": {
				"max": 255,
				"field": "_green"
			},
			"blue": {
				"max": 255,
				"field": "_blue"
			}
		}
	});
	Color.prototype.__ks_func_red_0 = function() {
		return this.getField("red");
	};
	Color.prototype.__ks_func_red_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("red", value);
	};
	Color.prototype.__ks_func_green_0 = function() {
		return this.getField("green");
	};
	Color.prototype.__ks_func_green_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("green", value);
	};
	Color.prototype.__ks_func_blue_0 = function() {
		return this.getField("blue");
	};
	Color.prototype.__ks_func_blue_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("blue", value);
	};
	Color.prototype.red = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_red_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_red_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	Color.prototype.green = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_green_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_green_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	Color.prototype.blue = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_blue_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_blue_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	return {
		Color: Color
	};
};