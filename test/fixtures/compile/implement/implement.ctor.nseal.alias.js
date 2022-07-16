const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
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
		__ks_func_color_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_color_0.call(that);
			}
			throw Helper.badArgs();
		}
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		__ks_func_draw_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_draw_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	Shape.__ks_new_1 = function() {
		const o = Object.create(Shape.prototype);
		o.__ks_init();
		o.__ks_cons_1();
		return o;
	};
	Shape.prototype.__ks_cons_1 = function() {
		this._color = "red";
	};
	Shape.prototype.__ks_cons_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 0) {
			return Shape.prototype.__ks_cons_1.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return Shape.prototype.__ks_cons_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let shape = Shape.__ks_new_1();
	expect(shape.__ks_func_draw_0()).to.equals("I'm drawing a red rectangle.");
};