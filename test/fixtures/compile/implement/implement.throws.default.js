var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._color = "";
		}
		__ks_init() {
			Shape.prototype.__ks_init_0.call(this);
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
		color() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_color_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Shape.prototype.__ks_func_color_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Shape.prototype.__ks_func_draw_0 = function(canvas) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(canvas === void 0 || canvas === null) {
			throw new TypeError("'canvas' is not nullable");
		}
		return Helper.concatString("I'm drawing a ", this.color(), " rectangle.");
	};
	Shape.prototype.draw = function() {
		if(arguments.length === 1) {
			return Shape.prototype.__ks_func_draw_0.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Shape: Shape
	};
};