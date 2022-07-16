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
		}
		__ks_cons_0(shape) {
			this._shape = shape;
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
	}
	const __ks_Shape = {};
	__ks_Shape.__ks_func_draw_0 = function(color) {
		if(color === void 0) {
			color = null;
		}
		if(Type.isValue(color)) {
			return Helper.concatString("I'm drawing a ", color, " ", this._shape, ".");
		}
		else {
			return "I'm drawing a " + this._shape + ".";
		}
	};
	__ks_Shape._im_draw = function(that, ...args) {
		return __ks_Shape.__ks_func_draw_rt(that, args);
	};
	__ks_Shape.__ks_func_draw_rt = function(that, args) {
		if(args.length === 1) {
			return __ks_Shape.__ks_func_draw_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	return {
		console,
		Shape,
		__ks_Shape
	};
};