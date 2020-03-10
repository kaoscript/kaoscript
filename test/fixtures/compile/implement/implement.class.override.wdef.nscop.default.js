var Type = require("@kaoscript/runtime").Type;
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
		__ks_func_draw_0(text) {
			if(text === void 0 || text === null) {
				text = "Hello!";
			}
			else if(!Type.isString(text)) {
				throw new TypeError("'text' is not of type 'String'");
			}
			return text;
		}
		draw() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Shape.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Shape.prototype.__ks_func_draw_0 = function(text) {
		if(text === void 0 || text === null) {
			text = "Hello!";
		}
		else if(!Type.isString(text)) {
			throw new TypeError("'text' is not of type 'String'");
		}
		return text + " I'm drawing a new shape.";
	};
	return {
		Shape: Shape
	};
};