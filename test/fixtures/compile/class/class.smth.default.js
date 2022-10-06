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
			this._type = "";
		}
		__ks_cons_0(type, color) {
			this._type = type;
			this._color = color;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return Shape.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_makeCircle_0(color) {
			return Shape.__ks_new_0("circle", color);
		}
		static makeCircle() {
			const t0 = Type.isString;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Shape.__ks_sttc_makeCircle_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_makeRectangle_0(color) {
			return Shape.__ks_new_0("rectangle", color);
		}
		static makeRectangle() {
			const t0 = Type.isString;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Shape.__ks_sttc_makeRectangle_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	let r = Shape.__ks_sttc_makeRectangle_0("black");
};