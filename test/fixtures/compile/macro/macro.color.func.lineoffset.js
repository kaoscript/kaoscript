require("kaoscript/register");
module.exports = function() {
	var {Space, Color} = require("../color.ks")();
	Color.registerSpace({
		"name": "rvb",
		"components": {
			"rouge": {
				"max": 255
			},
			"vert": {
				"max": 255
			},
			"blue": {
				"max": 255
			}
		}
	});
	Color.prototype.__ks_func_rouge_0 = function() {
		return this.getField("rouge");
	};
	Color.prototype.__ks_func_rouge_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("rouge", value);
	};
	Color.prototype.__ks_func_vert_0 = function() {
		return this.getField("vert");
	};
	Color.prototype.__ks_func_vert_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("vert", value);
	};
	Color.prototype.__ks_func_blue_0 = function() {
		return this.getField("blue");
	};
	Color.prototype.__ks_func_blue_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("blue", value);
	};
	Color.prototype.rouge = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_rouge_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_rouge_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.vert = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_vert_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_vert_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.registerSpace({
		"name": "cmy",
		"converters": {
			"from": {
				srgb(red, green, blue, that) {
					if(arguments.length < 4) {
						throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 4)");
					}
					if(red === void 0 || red === null) {
						throw new TypeError("'red' is not nullable");
					}
					if(green === void 0 || green === null) {
						throw new TypeError("'green' is not nullable");
					}
					if(blue === void 0 || blue === null) {
						throw new TypeError("'blue' is not nullable");
					}
					if(that === void 0 || that === null) {
						throw new TypeError("'that' is not nullable");
					}
					that._cyan = blue;
					that._magenta = red;
					that._yellow = green;
				}
			},
			"to": {
				srgb(cyan, magenta, yellow, that) {
					if(arguments.length < 4) {
						throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 4)");
					}
					if(cyan === void 0 || cyan === null) {
						throw new TypeError("'cyan' is not nullable");
					}
					if(magenta === void 0 || magenta === null) {
						throw new TypeError("'magenta' is not nullable");
					}
					if(yellow === void 0 || yellow === null) {
						throw new TypeError("'yellow' is not nullable");
					}
					if(that === void 0 || that === null) {
						throw new TypeError("'that' is not nullable");
					}
					that._red = magenta;
					that._green = yellow;
					that._blue = cyan;
				}
			}
		},
		"components": {
			"cyan": {
				"max": 255
			},
			"magenta": {
				"max": 255
			},
			"yellow": {
				"max": 255
			}
		}
	});
	Color.prototype.__ks_func_cyan_0 = function() {
		return this.getField("cyan");
	};
	Color.prototype.__ks_func_cyan_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("cyan", value);
	};
	Color.prototype.__ks_func_magenta_0 = function() {
		return this.getField("magenta");
	};
	Color.prototype.__ks_func_magenta_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("magenta", value);
	};
	Color.prototype.__ks_func_yellow_0 = function() {
		return this.getField("yellow");
	};
	Color.prototype.__ks_func_yellow_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("yellow", value);
	};
	Color.prototype.cyan = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_cyan_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_cyan_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.magenta = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_magenta_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_magenta_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.yellow = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_yellow_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_yellow_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};