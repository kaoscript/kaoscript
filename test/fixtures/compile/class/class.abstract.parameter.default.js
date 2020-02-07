var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class Rectangle extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Shape.prototype.__ks_cons.call(this, args);
		}
		__ks_func_draw_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			return Helper.concatString("I'm drawing a ", color, " rectangle.");
		}
		draw() {
			if(arguments.length === 1) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			else if(Shape.prototype.draw) {
				return Shape.prototype.draw.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	let r = new Rectangle();
	console.log(r.draw("black"));
};