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
				throw new SyntaxError("wrong number of arguments");
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
			throw new SyntaxError("wrong number of arguments");
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
		throw new SyntaxError("wrong number of arguments");
	};
	class Proxy {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			this._shape = new Shape(color);
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Proxy.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_draw_0() {
			return __ks_Shape._im_draw(this._shape);
		}
		__ks_func_draw_1(shape) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(shape === void 0 || shape === null) {
				throw new TypeError("'shape' is not nullable");
			}
			return __ks_Shape._im_draw(this._shape, shape);
		}
		__ks_func_draw_2(color, shape) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			if(shape === void 0 || shape === null) {
				throw new TypeError("'shape' is not nullable");
			}
			return __ks_Shape._im_draw(this._shape, color, shape);
		}
		draw() {
			if(arguments.length === 0) {
				return Proxy.prototype.__ks_func_draw_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Proxy.prototype.__ks_func_draw_1.apply(this, arguments);
			}
			else if(arguments.length === 2) {
				return Proxy.prototype.__ks_func_draw_2.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	let shape = new Proxy("yellow");
	console.log(shape.draw("rectangle"));
	console.log(shape.draw("red", "rectangle"));
}