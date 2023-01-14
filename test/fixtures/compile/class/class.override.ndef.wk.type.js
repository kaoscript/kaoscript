require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	class Shape {
		static __ks_new_0(...args) {
			const o = Object.create(Shape.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(color) {
			this._color = color;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Shape.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_0(text) {
			return this._color;
		}
		__ks_func_draw_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_draw_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Rectangle extends Shape {
		static __ks_new_0(...args) {
			const o = Object.create(Rectangle.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(color) {
			Shape.prototype.__ks_cons_0.call(this, color);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Rectangle.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		__ks_func_draw_0(text) {
			let fragments = "";
			for(let __ks_2 = __ks_String.__ks_func_lines_0.call(text), __ks_1 = 0, __ks_0 = __ks_2.length, line; __ks_1 < __ks_0; ++__ks_1) {
				line = __ks_2[__ks_1];
			}
			return fragments;
		}
	}
	let r = Rectangle.__ks_new_0("black");
	console.log(r.__ks_func_draw_0("foo\nbar"));
	return {
		Shape,
		Rectangle
	};
};