const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Space = Helper.enum(String, {
		RGB: "rgb",
		SRGB: "srgb"
	});
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
			this._alpha = 1;
			this._red = 0;
			this._green = 0;
			this._blue = 0;
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
		red() {
			return this.__ks_func_red_rt.call(null, this, this, arguments);
		}
		__ks_func_red_0() {
			return this.__ks_func_getField_0("red");
		}
		__ks_func_red_1(value) {
			return this.__ks_func_setField_0("red", value);
		}
		__ks_func_red_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_red_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_red_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		green() {
			return this.__ks_func_green_rt.call(null, this, this, arguments);
		}
		__ks_func_green_0() {
			return this.__ks_func_getField_0("green");
		}
		__ks_func_green_1(value) {
			return this.__ks_func_setField_0("green", value);
		}
		__ks_func_green_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_green_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_green_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		blue() {
			return this.__ks_func_blue_rt.call(null, this, this, arguments);
		}
		__ks_func_blue_0() {
			return this.__ks_func_getField_0("blue");
		}
		__ks_func_blue_1(value) {
			return this.__ks_func_setField_0("blue", value);
		}
		__ks_func_blue_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_blue_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_blue_1.call(that, args[0]);
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
	Color.__ks_sttc_addSpace_0((() => {
		const o = new OBJ();
		o.name = Space.SRGB;
		o["alias"] = [Space.RGB];
		o["formatters"] = (() => {
			const o = new OBJ();
			o.hex = Helper.function(function(that) {
				return $hex(that);
			}, (that, fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			o.srgb = Helper.function(function(that) {
				if(that._alpha === 1) {
					return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
				}
				else {
					return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
				}
			}, (that, fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			return o;
		})();
		o["components"] = (() => {
			const o = new OBJ();
			o["red"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				o["field"] = "_red";
				return o;
			})();
			o["green"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				o["field"] = "_green";
				return o;
			})();
			o["blue"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				o["field"] = "_blue";
				return o;
			})();
			return o;
		})();
		return o;
	})());
	return {
		Color
	};
};