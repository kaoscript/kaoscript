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
			if(color === void 0 || color === null) {
				color = "black";
			}
			this._color = color;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return Shape.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
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
		name() {
			return this.__ks_func_name_rt.call(null, this, this, arguments);
		}
		__ks_func_name_0() {
			return this._name;
		}
		__ks_func_name_1(name) {
			if(name === void 0) {
				name = null;
			}
			this._name = name;
			return this;
		}
		__ks_func_name_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_name_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_name_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		toString() {
			return this.__ks_func_toString_rt.call(null, this, this, arguments);
		}
		__ks_func_toString_0() {
			return Helper.concatString("I'm drawing a ", this._color, " ", this._name, ".");
		}
		__ks_func_toString_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_toString_0.call(that);
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
	const shape = Shape.__ks_sttc_makeBlue_0();
	console.log(shape.__ks_func_toString_0());
};