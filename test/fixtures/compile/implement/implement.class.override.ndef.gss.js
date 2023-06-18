const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		static __ks_new_0() {
			const o = Object.create(Shape.prototype);
			o.__ks_init();
			return o;
		}
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
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_0(text) {
			return text;
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
	return {
		Shape
	};
};