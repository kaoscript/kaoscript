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
	}
	Shape.prototype.__ks_func_draw_es6_0 = function(canvas) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(canvas === void 0 || canvas === null) {
			throw new TypeError("'canvas' is not nullable");
		}
		return "I'm drawing a " + this._color + " rectangle.";
	};
	Shape.prototype.draw_es6 = function() {
		if(arguments.length === 1) {
			return Shape.prototype.__ks_func_draw_es6_0.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
};