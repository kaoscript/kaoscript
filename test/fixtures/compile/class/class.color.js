var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Space = Helper.enum(String, {
		RGB: "rgb"
	});
	class Color {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._blue = 0;
			this._green = 0;
			this._red = 0;
			this._space = Space.RGB;
		}
		__ks_init() {
			Color.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_space_0() {
			return this._space;
		}
		__ks_func_space_1(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(space === void 0 || space === null) {
				throw new TypeError("'space' is not nullable");
			}
			else if(!Type.isEnumInstance(space, Space)) {
				throw new TypeError("'space' is not of type 'Space'");
			}
			this._space = space;
			return this;
		}
		space() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_space_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Color.prototype.__ks_func_space_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	return {
		Color: Color,
		Space: Space
	};
};