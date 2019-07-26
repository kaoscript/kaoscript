var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Rectangle {
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
				Rectangle.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_draw_0(canvas) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(canvas === void 0 || canvas === null) {
				throw new TypeError("'canvas' is not nullable");
			}
			return "I'm drawing a " + this._color + " rectangle.";
		}
		draw() {
			if(arguments.length === 1) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Object.defineProperty(Rectangle, 'version', {
		value: [1, 0, 0]
	});
	console.log(Rectangle.name);
	console.log(Rectangle.version);
};