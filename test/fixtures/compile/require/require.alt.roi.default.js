require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Shape) {
	const PI = 3.14;
	if(!Type.isValue(Shape)) {
		var Shape = require("../export/export.class.default.ks")().Shape;
	}
	Shape.prototype.__ks_func_color_0 = function() {
		return this._color;
	};
	Shape.prototype.__ks_func_color_1 = function(color) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		else if(!Type.isString(color)) {
			throw new TypeError("'color' is not of type 'String'");
		}
		this._color = color;
		return this;
	};
	Shape.prototype.color = function() {
		if(arguments.length === 0) {
			return Shape.prototype.__ks_func_color_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Shape.prototype.__ks_func_color_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Shape: Shape
	};
};