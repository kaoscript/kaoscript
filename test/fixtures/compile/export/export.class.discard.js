var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Color {
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
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons_1(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			this._name = name;
		}
		__ks_cons_2(name, color) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			this._name = name;
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Shape.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Shape.prototype.__ks_cons_1.apply(this, args);
			}
			else if(args.length === 2) {
				Shape.prototype.__ks_cons_2.apply(this, args);
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
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
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
		__ks_func_name_0() {
			return this._name;
		}
		__ks_func_name_1(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			this._name = name;
			return this;
		}
		name() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_name_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Shape.prototype.__ks_func_name_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	return {
		Shape: Shape
	};
};