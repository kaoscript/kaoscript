require("kaoscript/register");
var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var {Space, Color} = require("../color.ks")();
	Color.registerSpace((() => {
		const d = new Dictionary();
		d["name"] = "rvb";
		d["converters"] = (() => {
			const d = new Dictionary();
			d["from"] = (() => {
				const d = new Dictionary();
				d.srgb = function(red, green, blue, that) {
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
					that._rouge = red;
					that._vert = green;
					that._blue = blue;
				};
				return d;
			})();
			d["to"] = (() => {
				const d = new Dictionary();
				d.srgb = function(rouge, vert, blue, that) {
					if(arguments.length < 4) {
						throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 4)");
					}
					if(rouge === void 0 || rouge === null) {
						throw new TypeError("'rouge' is not nullable");
					}
					if(vert === void 0 || vert === null) {
						throw new TypeError("'vert' is not nullable");
					}
					if(blue === void 0 || blue === null) {
						throw new TypeError("'blue' is not nullable");
					}
					if(that === void 0 || that === null) {
						throw new TypeError("'that' is not nullable");
					}
					that._red = rouge;
					that._green = vert;
					that._blue = blue;
				};
				return d;
			})();
			return d;
		})();
		d["components"] = (() => {
			const d = new Dictionary();
			d["rouge"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			d["vert"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			d["blue"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_init_4 = function() {
		this._rouge = 0;
	};
	Color.prototype.__ks_init_5 = function() {
		this._vert = 0;
	};
	Color.prototype.__ks_init_6 = function() {
		this._blue = 0;
	};
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
	Color.prototype.__ks_init = function() {
		Color.prototype.__ks_init_0.call(this);
		Color.prototype.__ks_init_1.call(this);
		Color.prototype.__ks_init_2.call(this);
		Color.prototype.__ks_init_3.call(this);
		Color.prototype.__ks_init_4.call(this);
		Color.prototype.__ks_init_5.call(this);
		Color.prototype.__ks_init_6.call(this);
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
	return {
		Color: Color
	};
};