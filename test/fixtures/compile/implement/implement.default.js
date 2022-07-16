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
			this._color = "";
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
		color() {
			return this.__ks_func_color_rt.call(null, this, this, arguments);
		}
		__ks_func_color_0() {
			return this._color;
		}
		__ks_func_color_1(color) {
			this._color = color;
			return this;
		}
		__ks_func_color_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_color_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_color_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Shape.prototype.__ks_func_draw_0 = function(canvas) {
		return "I'm drawing a " + this._color + " rectangle.";
	};
	Shape.prototype.__ks_func_draw_rt = function(that, proto, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_draw_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Shape.prototype.draw = function() {
		return this.__ks_func_draw_rt.call(null, this, this, arguments);
	};
	return {
		Shape
	};
};