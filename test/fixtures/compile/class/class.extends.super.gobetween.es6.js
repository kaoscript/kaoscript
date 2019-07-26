var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
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
		__ks_func_draw_0() {
			return "I'm drawing with a " + this._color + " pen.";
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Quadrilateral extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Shape.prototype.__ks_cons.call(this, args);
		}
	}
	class Rectangle extends Quadrilateral {
		__ks_init() {
			Quadrilateral.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Quadrilateral.prototype.__ks_cons.call(this, args);
		}
		__ks_func_draw_0() {
			return super.draw() + " I'm drawing a " + this._color + " rectangle.";
		}
		draw() {
			if(arguments.length === 0) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this);
			}
			return Quadrilateral.prototype.draw.apply(this, arguments);
		}
	}
	let r = new Rectangle("black");
	console.log(r.draw());
};