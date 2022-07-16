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
			return "I'm drawing with a " + this._color + " pencil.";
		}
		__ks_func_draw_1(shape) {
			return Helper.concatString("I'm drawing a ", this._color, " ", shape, ".");
		}
		draw() {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return this.__ks_func_draw_0();
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return this.__ks_func_draw_1(args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	const __ks_Shape = {};
	__ks_Shape.__ks_func_draw_2 = function(color, shape) {
		return Helper.concatString("I'm drawing a ", color, " ", shape, ".");
	};
	__ks_Shape._im_draw = function(that, ...args) {
		return __ks_Shape.__ks_func_draw_rt(that, args);
	};
	__ks_Shape.__ks_func_draw_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 0) {
			return that.__ks_func_draw_0();
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return that.__ks_func_draw_1(args[0]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_Shape.__ks_func_draw_2.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	let shape = Shape.__ks_new_0("yellow");
	console.log(shape.__ks_func_draw_1("rectangle"));
	console.log(__ks_Shape.__ks_func_draw_2.call(shape, "red", "rectangle"));
};