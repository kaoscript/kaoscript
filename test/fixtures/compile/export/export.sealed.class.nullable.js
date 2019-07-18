var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_cons(arguments);
		}
		__ks_cons_0(shape) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(shape === void 0 || shape === null) {
				throw new TypeError("'shape' is not nullable");
			}
			else if(!Type.isString(shape)) {
				throw new TypeError("'shape' is not of type 'String'");
			}
			this._shape = shape;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	var __ks_Shape = {};
	__ks_Shape.__ks_func_draw_0 = function(color) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(color === void 0) {
			color = null;
		}
		if(Type.isValue(color)) {
			return "I'm drawing a " + color + " " + this._shape + ".";
		}
		else {
			return "I'm drawing a " + this._shape + ".";
		}
	};
	__ks_Shape._im_draw = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Shape.__ks_func_draw_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		console: console,
		Shape: Shape,
		__ks_Shape: __ks_Shape
	};
};