require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Space = require("../export/.export.enum.space.ks.j5k8r9.ksb")().Space;
	class Color {
		static __ks_new_0() {
			const o = Object.create(Color.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._hue = 0;
			this._saturation = 0;
			this._lightness = 0;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		getField() {
			return this.__ks_func_getField_rt.call(null, this, this, arguments);
		}
		__ks_func_getField_0(name) {
		}
		__ks_func_getField_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_getField_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		setField() {
			return this.__ks_func_setField_rt.call(null, this, this, arguments);
		}
		__ks_func_setField_0(name, value) {
		}
		__ks_func_setField_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return proto.__ks_func_setField_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		hue() {
			return this.__ks_func_hue_rt.call(null, this, this, arguments);
		}
		__ks_func_hue_0() {
			return this.__ks_func_getField_0("hue");
		}
		__ks_func_hue_1(value) {
			return this.__ks_func_setField_0("hue", value);
		}
		__ks_func_hue_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_hue_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_hue_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		saturation() {
			return this.__ks_func_saturation_rt.call(null, this, this, arguments);
		}
		__ks_func_saturation_0() {
			return this.__ks_func_getField_0("saturation");
		}
		__ks_func_saturation_1(value) {
			return this.__ks_func_setField_0("saturation", value);
		}
		__ks_func_saturation_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_saturation_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_saturation_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		lightness() {
			return this.__ks_func_lightness_rt.call(null, this, this, arguments);
		}
		__ks_func_lightness_0() {
			return this.__ks_func_getField_0("lightness");
		}
		__ks_func_lightness_1(value) {
			return this.__ks_func_setField_0("lightness", value);
		}
		__ks_func_lightness_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_lightness_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_lightness_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_addSpace_0(data) {
		}
		static addSpace() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Color.__ks_sttc_addSpace_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Helper.implEnum(Space, "HSB", "hsb", "HSL", "hsl");
	Color.__ks_sttc_addSpace_0((() => {
		const o = new OBJ();
		o.name = Space.HSL;
		o["components"] = (() => {
			const o = new OBJ();
			o["hue"] = (() => {
				const o = new OBJ();
				o.family = Space.HSB;
				o["field"] = "_hue";
				return o;
			})();
			o["saturation"] = (() => {
				const o = new OBJ();
				o.family = Space.HSB;
				o["field"] = "_saturation";
				return o;
			})();
			o["lightness"] = (() => {
				const o = new OBJ();
				o["max"] = 100;
				o["round"] = 1;
				o["field"] = "_lightness";
				return o;
			})();
			return o;
		})();
		return o;
	})());
};