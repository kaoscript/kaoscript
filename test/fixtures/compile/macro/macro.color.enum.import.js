require("kaoscript/register");
module.exports = function() {
	var Space = require("../export/export.enum.space.ks")().Space;
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
	Space.HSB = "hsb";
	Space.HSL = "hsl";
	Color.registerSpace({
		name: Space.HSL,
		"components": {
			"hue": {
				family: Space.HSB,
				"field": "_hue"
			},
			"saturation": {
				family: Space.HSB,
				"field": "_saturation"
			},
			"lightness": {
				"max": 100,
				"round": 1,
				"field": "_lightness"
			}
		}
	});
	Color.prototype.__ks_func_hue_0 = function() {
		return this.getField("hue");
	};
	Color.prototype.__ks_func_hue_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("hue", value);
	};
	Color.prototype.__ks_func_saturation_0 = function() {
		return this.getField("saturation");
	};
	Color.prototype.__ks_func_saturation_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("saturation", value);
	};
	Color.prototype.__ks_func_lightness_0 = function() {
		return this.getField("lightness");
	};
	Color.prototype.__ks_func_lightness_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("lightness", value);
	};
	Color.prototype.hue = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_hue_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_hue_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	Color.prototype.saturation = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_saturation_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_saturation_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	Color.prototype.lightness = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_lightness_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_lightness_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
};