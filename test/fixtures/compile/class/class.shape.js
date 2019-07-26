var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._color = "";
		}
		__ks_init() {
			Shape.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(color) {
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
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_color_0() {
			return this._color;
		}
		__ks_func_color_1(color) {
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
		}
		__ks_func_color_2(shape) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(shape === void 0 || shape === null) {
				throw new TypeError("'shape' is not nullable");
			}
			else if(!Type.is(shape, Shape)) {
				throw new TypeError("'shape' is not of type 'Shape'");
			}
			this._color = shape.color();
			return this;
		}
		color() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_color_0.apply(this);
			}
			else if(arguments.length === 1) {
				if(Type.isString(arguments[0])) {
					return Shape.prototype.__ks_func_color_1.apply(this, arguments);
				}
				else {
					return Shape.prototype.__ks_func_color_2.apply(this, arguments);
				}
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	let s = new Shape("#777");
	console.log(s.color());
};