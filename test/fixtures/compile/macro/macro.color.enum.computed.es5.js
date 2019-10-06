var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper;
module.exports = function() {
	var Space = Helper.enum(String, {
		RGB: "rgb",
		SRGB: "srgb",
		YUV: "yuv"
	});
	var Color = Helper.class({
		$name: "Color",
		$static: {
			__ks_sttc_registerSpace_0: function(data) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(data === void 0 || data === null) {
					throw new TypeError("'data' is not nullable");
				}
			},
			registerSpace: function() {
				if(arguments.length === 1) {
					return Color.__ks_sttc_registerSpace_0.apply(this, arguments);
				}
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_getField_0: function(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
		},
		getField: function() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_getField_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		},
		__ks_func_setField_0: function(name, value) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
		},
		setField: function() {
			if(arguments.length === 2) {
				return Color.prototype.__ks_func_setField_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
	Color.registerSpace((function() {
		var d = new Dictionary();
		d.name = Space.SRGB;
		d["alias"] = [Space.RGB];
		d["parsers"] = (function() {
			var d = new Dictionary();
			d["from"] = (function() {
				var d = new Dictionary();
				d.hex = function() {
					return "HEX -> RGB";
				};
				d[Space.YUV] = function() {
					return "YUV -> RGB";
				};
				return d;
			})();
			return d;
		})();
		d["components"] = (function() {
			var d = new Dictionary();
			d["red"] = (function() {
				var d = new Dictionary();
				d["max"] = 255;
				d["field"] = "_red";
				return d;
			})();
			d["green"] = (function() {
				var d = new Dictionary();
				d["max"] = 255;
				d["field"] = "_green";
				return d;
			})();
			d["blue"] = (function() {
				var d = new Dictionary();
				d["max"] = 255;
				d["field"] = "_blue";
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_func_red_0 = function() {
		return this.getField("red");
	};
	Color.prototype.__ks_func_red_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.green = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_green_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_green_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.blue = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_blue_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_blue_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};