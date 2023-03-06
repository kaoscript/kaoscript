const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		static __ks_new_0(...args) {
			const o = Object.create(Shape.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt(arguments);
		}
		__ks_init() {
			this._color = "black";
		}
		__ks_cons_0(color) {
			this._color = color;
		}
		__ks_cons_rt(args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Shape.prototype.__ks_cons_0.call(this, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_destroy_0(that) {
			that._color = null;
		}
		static __ks_destroy(that) {
			Shape.__ks_destroy_0(that);
		}
		__ks_func_draw_0() {
			throw new Error("Not Implemented");
		}
		draw(...args) {
			if(args.length === 0) {
				return this.__ks_func_draw_0();
			}
			throw Helper.badArgs();
		}
	}
	const __ks_Shape = {};
	class Rectangle extends Shape {
		static __ks_new_0(...args) {
			const o = Object.create(Rectangle.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._foo = "bar";
		}
		__ks_cons_0(color) {
			Shape.prototype.__ks_cons_rt.call(null, this, [color]);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Rectangle.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_destroy_0(that) {
			that._foo = null;
		}
		static __ks_destroy(that) {
			Shape.__ks_destroy(that);
			Rectangle.__ks_destroy_0(that);
		}
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
	}
};