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
	Shape.prototype.__ks_func_draw_0 = function(text) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(text === void 0 || text === null) {
			throw new TypeError("'text' is not nullable");
		}
		return "I'm drawing a new shape.";
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