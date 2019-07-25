var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this._color = "";
			this.__ks_cons(arguments);
		}
		__ks_cons_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_draw_0() {
			return "I'm drawing with a " + this._color + " pencil.";
		}
		__ks_func_draw_1(shape) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(shape === void 0 || shape === null) {
				throw new TypeError("'shape' is not nullable");
			}
			return "I'm drawing a " + this._color + " " + shape + ".";
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Shape.prototype.__ks_func_draw_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	var __ks_Shape = {};
	__ks_Shape.__ks_func_draw_2 = function(color, shape) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		if(shape === void 0 || shape === null) {
			throw new TypeError("'shape' is not nullable");
		}
		return "I'm drawing a " + color + " " + shape + ".";
	};
	__ks_Shape._im_draw = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return Shape.prototype.__ks_func_draw_0.apply(that);
		}
		else if(args.length === 1) {
			return Shape.prototype.__ks_func_draw_1.apply(that, args);
		}
		else if(args.length === 2) {
			return __ks_Shape.__ks_func_draw_2.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	let shape = new Shape("yellow");
	console.log(shape.draw("rectangle"));
	console.log(__ks_Shape._im_draw(shape, "red", "rectangle"));
};