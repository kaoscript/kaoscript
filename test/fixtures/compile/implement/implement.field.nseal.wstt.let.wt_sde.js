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
			if(color === void 0 || color === null) {
				color = "black";
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
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
		static __ks_sttc_makeBlue_0() {
			return new Shape("blue");
		}
		static makeBlue() {
			if(arguments.length === 0) {
				return Shape.__ks_sttc_makeBlue_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Shape.NAME = "circle";
	console.log("name: " + Shape.NAME);
};