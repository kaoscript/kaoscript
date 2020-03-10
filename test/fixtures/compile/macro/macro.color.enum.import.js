require("kaoscript/register");
var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var Space = require("../export/export.enum.space.ks")().Space;
	class Color {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_getField_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
		}
		getField() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_getField_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_setField_0(name, value) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
		}
		setField() {
			if(arguments.length === 2) {
				return Color.prototype.__ks_func_setField_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_registerSpace_0(data) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
		}
		static registerSpace() {
			if(arguments.length === 1) {
				return Color.__ks_sttc_registerSpace_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Space.HSB = Space("hsb");
	Space.HSL = Space("hsl");
	Color.registerSpace((() => {
		const d = new Dictionary();
		d.name = Space.HSL;
		d["components"] = (() => {
			const d = new Dictionary();
			d["hue"] = (() => {
				const d = new Dictionary();
				d.family = Space.HSB;
				d["field"] = "_hue";
				return d;
			})();
			d["saturation"] = (() => {
				const d = new Dictionary();
				d.family = Space.HSB;
				d["field"] = "_saturation";
				return d;
			})();
			d["lightness"] = (() => {
				const d = new Dictionary();
				d["max"] = 100;
				d["round"] = 1;
				d["field"] = "_lightness";
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_init_0 = function() {
		this._hue = 0;
	};
	Color.prototype.__ks_init_1 = function() {
		this._saturation = 0;
	};
	Color.prototype.__ks_init_2 = function() {
		this._lightness = 0;
	};
	Color.prototype.__ks_func_hue_0 = function() {
		return this.getField("hue");
	};
	Color.prototype.__ks_func_hue_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("hue", value);
	};
	Color.prototype.__ks_func_saturation_0 = function() {
		return this.getField("saturation");
	};
	Color.prototype.__ks_func_saturation_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("saturation", value);
	};
	Color.prototype.__ks_func_lightness_0 = function() {
		return this.getField("lightness");
	};
	Color.prototype.__ks_func_lightness_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("lightness", value);
	};
	Color.prototype.__ks_init = function() {
		Color.prototype.__ks_init_0.call(this);
		Color.prototype.__ks_init_1.call(this);
		Color.prototype.__ks_init_2.call(this);
	};
	Color.prototype.hue = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_hue_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_hue_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.saturation = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_saturation_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_saturation_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.lightness = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_lightness_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_lightness_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};