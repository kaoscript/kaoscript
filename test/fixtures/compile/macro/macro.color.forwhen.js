const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
		const d = new OBJ();
		d["name"] = "srgb";
		d["alias"] = ["rgb"];
		d["components"] = (() => {
			const d = new OBJ();
			d["red"] = (() => {
				const d = new OBJ();
				d["family"] = "foobar";
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
				d["family"] = "foobar";
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_func_green_0 = function() {
		return this.__ks_func_getField_0("green");
	};
	Color.prototype.__ks_func_green_1 = function(value) {
		return this.__ks_func_setField_0("green", value);
	};
	Color.prototype.__ks_init_0 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_0();
		this._green = 0;
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
	return {
		Color
	};
};