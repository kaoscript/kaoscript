const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	class Rectangle extends Shape {
		static __ks_new_0() {
			const o = Object.create(Rectangle.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_1(color) {
			return Helper.concatString("I'm drawing a ", color, " rectangle.");
		}
		__ks_func_draw_0(color) {
			return this.__ks_func_draw_1(color);
		}
		__ks_func_draw_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_draw_1.call(that, args[0]);
				}
			}
			if(super.__ks_func_draw_rt) {
				return super.__ks_func_draw_rt.call(null, that, Shape.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	let r = Rectangle.__ks_new_0();
	console.log(r.__ks_func_draw_1("black"));
};