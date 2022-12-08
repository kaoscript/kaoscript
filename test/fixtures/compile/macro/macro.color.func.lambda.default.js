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
	Color.__ks_sttc_registerSpace_0((() => {
		const d = new OBJ();
		d.name = Space.SRGB;
		d["alias"] = [Space.RGB];
		d["formatters"] = (() => {
			const d = new OBJ();
			d.hex = Helper.function(function(that) {
				return $hex(that);
			}, (fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			d.srgb = Helper.function(function(that) {
				if(that._alpha === 1) {
					return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
				}
				else {
					return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
				}
			}, (fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			return d;
		})();
		d["components"] = (() => {
			const d = new OBJ();
			d["red"] = (() => {
				const d = new OBJ();
				d["max"] = 255;
				d["field"] = "_red";
				return d;
			})();
			d["green"] = (() => {
				const d = new OBJ();
				d["max"] = 255;
				d["field"] = "_green";
				return d;
			})();
			d["blue"] = (() => {
				const d = new OBJ();
				d["max"] = 255;
				d["field"] = "_blue";
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_func_red_0 = function() {
		return this.__ks_func_getField_0("red");
	};
	Color.prototype.__ks_func_red_1 = function(value) {
		return this.__ks_func_setField_0("red", value);
	};
	Color.prototype.__ks_func_green_0 = function() {
		return this.__ks_func_getField_0("green");
	};
	Color.prototype.__ks_func_green_1 = function(value) {
		return this.__ks_func_setField_0("green", value);
	};
	Color.prototype.__ks_func_blue_0 = function() {
		return this.__ks_func_getField_0("blue");
	};
	Color.prototype.__ks_func_blue_1 = function(value) {
		return this.__ks_func_setField_0("blue", value);
	};
	Color.prototype.__ks_init_1 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_1();
		this._red = 0;
		this._green = 0;
		this._blue = 0;
	};
	Color.prototype.__ks_func_red_rt = function(that, proto, args) {
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
	};
	Color.prototype.red = function() {
		return this.__ks_func_red_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_green_rt = function(that, proto, args) {
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
	};
	Color.prototype.green = function() {
		return this.__ks_func_green_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_blue_rt = function(that, proto, args) {
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
	};
	Color.prototype.blue = function() {
		return this.__ks_func_blue_rt.call(null, this, this, arguments);
	};
	return {
		Color
	};
};