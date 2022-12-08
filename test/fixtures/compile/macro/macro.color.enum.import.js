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
		static __ks_sttc_registerSpace_0(data) {
		}
		static registerSpace() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Color.__ks_sttc_registerSpace_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Space.HSB = Space("hsb");
	Space.HSL = Space("hsl");
	Color.__ks_sttc_registerSpace_0((() => {
		const d = new OBJ();
		d.name = Space.HSL;
		d["components"] = (() => {
			const d = new OBJ();
			d["hue"] = (() => {
				const d = new OBJ();
				d.family = Space.HSB;
				d["field"] = "_hue";
				return d;
			})();
			d["saturation"] = (() => {
				const d = new OBJ();
				d.family = Space.HSB;
				d["field"] = "_saturation";
				return d;
			})();
			d["lightness"] = (() => {
				const d = new OBJ();
				d["max"] = 100;
				d["round"] = 1;
				d["field"] = "_lightness";
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_func_hue_0 = function() {
		return this.__ks_func_getField_0("hue");
	};
	Color.prototype.__ks_func_hue_1 = function(value) {
		return this.__ks_func_setField_0("hue", value);
	};
	Color.prototype.__ks_func_saturation_0 = function() {
		return this.__ks_func_getField_0("saturation");
	};
	Color.prototype.__ks_func_saturation_1 = function(value) {
		return this.__ks_func_setField_0("saturation", value);
	};
	Color.prototype.__ks_func_lightness_0 = function() {
		return this.__ks_func_getField_0("lightness");
	};
	Color.prototype.__ks_func_lightness_1 = function(value) {
		return this.__ks_func_setField_0("lightness", value);
	};
	Color.prototype.__ks_init_0 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_0();
		this._hue = 0;
		this._saturation = 0;
		this._lightness = 0;
	};
	Color.prototype.__ks_func_hue_rt = function(that, proto, args) {
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
	};
	Color.prototype.hue = function() {
		return this.__ks_func_hue_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_saturation_rt = function(that, proto, args) {
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
	};
	Color.prototype.saturation = function() {
		return this.__ks_func_saturation_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_lightness_rt = function(that, proto, args) {
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
	};
	Color.prototype.lightness = function() {
		return this.__ks_func_lightness_rt.call(null, this, this, arguments);
	};
};