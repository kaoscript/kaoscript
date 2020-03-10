var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
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
		color() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_color_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Shape.prototype.__ks_cons_1 = function() {
		this._color = "red";
	};
	Shape.prototype.__ks_cons = function(args) {
		if(args.length === 0) {
			Shape.prototype.__ks_cons_1.apply(this);
		}
		else if(args.length === 1) {
			Shape.prototype.__ks_cons_0.apply(this, args);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	let shape = new Shape();
	expect(shape.draw()).to.equals("I'm drawing a red rectangle.");
};