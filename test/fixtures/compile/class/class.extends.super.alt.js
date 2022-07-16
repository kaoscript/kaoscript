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
		pen() {
			return this.__ks_func_pen_rt.call(null, this, this, arguments);
		}
		__ks_func_pen_0() {
			return "I'm drawing with a " + this._color + " pen.";
		}
		__ks_func_pen_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_pen_0.call(that);
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
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_0() {
			return super.__ks_func_pen_0() + " I'm drawing a " + this._color + " rectangle.";
		}
		__ks_func_draw_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_draw_0.call(that);
			}
			if(super.__ks_func_draw_rt) {
				return super.__ks_func_draw_rt.call(null, that, Shape.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	let r = Rectangle.__ks_new_0("black");
	console.log(r.__ks_func_draw_0());
};