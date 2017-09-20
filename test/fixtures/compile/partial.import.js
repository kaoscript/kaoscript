require("kaoscript/register");
module.exports = function() {
	var Shape = require("./export.class.default.ks")().Shape;
	Shape.prototype.__ks_func_draw_0 = function(canvas) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(canvas === void 0 || canvas === null) {
			throw new TypeError("'canvas' is not nullable");
		}
		return "I'm drawing a " + this._color + " rectangle.";
	};
	Shape.prototype.draw = function() {
		if(arguments.length === 1) {
			return Shape.prototype.__ks_func_draw_0.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
};