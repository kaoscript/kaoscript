require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
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
		__ks_func_draw_0(text) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(text === void 0 || text === null) {
				throw new TypeError("'text' is not nullable");
			}
			else if(!Type.isString(text)) {
				throw new TypeError("'text' is not of type 'String'");
			}
			return this._color;
		}
		draw() {
			if(arguments.length === 1) {
				return Shape.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Rectangle extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
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
			Shape.prototype.__ks_cons.call(this, [color]);
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Rectangle.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_draw_0(text) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(text === void 0 || text === null) {
				throw new TypeError("'text' is not nullable");
			}
			else if(!Type.isString(text)) {
				throw new TypeError("'text' is not of type 'String'");
			}
			let fragments = "";
			for(let __ks_0 = 0, __ks_1 = __ks_String._im_lines(text), __ks_2 = __ks_1.length, line; __ks_0 < __ks_2; ++__ks_0) {
				line = __ks_1[__ks_0];
			}
			return fragments;
		}
		draw() {
			if(arguments.length === 1) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			return Shape.prototype.draw.apply(this, arguments);
		}
	}
	let r = new Rectangle("black");
	console.log(r.draw("foo\nbar"));
	return {
		Shape: Shape,
		Rectangle: Rectangle
	};
};