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
			this._color = "";
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
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		draw(...args) {
			if(args.length === 0) {
				return this.__ks_func_draw_0();
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_makeBlue_0() {
			return Shape.__ks_new_0("blue");
		}
		static makeBlue() {
			if(arguments.length === 0) {
				return Shape.__ks_sttc_makeBlue_0();
			}
			throw Helper.badArgs();
		}
	}
	const __ks_Shape = {};
	__ks_Shape.__ks_sttc_makeRed_0 = function() {
		return Shape.__ks_new_0("red");
	};
	__ks_Shape._sm_makeRed = function() {
		if(arguments.length === 0) {
			return __ks_Shape.__ks_sttc_makeRed_0();
		}
		throw Helper.badArgs();
	};
	let shape = Shape.__ks_sttc_makeBlue_0();
	console.log(shape.__ks_func_draw_0());
	shape = __ks_Shape.__ks_sttc_makeRed_0();
	console.log(shape.__ks_func_draw_0());
};