require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Color, Space} = require("../.color.ks.j5k8r9.ksb")();
	Space.RVB = Space("rvb");
	Color.__ks_sttc_addSpace_0((() => {
		const o = new OBJ();
		o["name"] = "rvb";
		o["converters"] = (() => {
			const o = new OBJ();
			o["from"] = (() => {
				const o = new OBJ();
				o.srgb = Helper.function(function(red, green, blue, that) {
					that._rouge = red;
					that._vert = green;
					that._blue = blue;
				}, (that, fn, ...args) => {
					const t0 = Type.isValue;
					if(args.length === 4) {
						if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3])) {
							return fn.call(null, args[0], args[1], args[2], args[3]);
						}
					}
					throw Helper.badArgs();
				});
				return o;
			})();
			o["to"] = (() => {
				const o = new OBJ();
				o.srgb = Helper.function(function(rouge, vert, blue, that) {
					that._red = rouge;
					that._green = vert;
					that._blue = blue;
				}, (that, fn, ...args) => {
					const t0 = Type.isValue;
					if(args.length === 4) {
						if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3])) {
							return fn.call(null, args[0], args[1], args[2], args[3]);
						}
					}
					throw Helper.badArgs();
				});
				return o;
			})();
			return o;
		})();
		o["components"] = (() => {
			const o = new OBJ();
			o["rouge"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				return o;
			})();
			o["vert"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				return o;
			})();
			o["blue"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				return o;
			})();
			return o;
		})();
		return o;
	})());
	Color.prototype.__ks_func_rouge_0 = function() {
		return this.__ks_func_getField_0("rouge");
	};
	Color.prototype.__ks_func_rouge_1 = function(value) {
		return this.setField("rouge", value);
	};
	Color.prototype.__ks_func_vert_0 = function() {
		return this.__ks_func_getField_0("vert");
	};
	Color.prototype.__ks_func_vert_1 = function(value) {
		return this.setField("vert", value);
	};
	Color.prototype.__ks_func_blue_0 = function() {
		return this.__ks_func_getField_0("blue");
	};
	Color.prototype.__ks_func_blue_1 = function(value) {
		return this.setField("blue", value);
	};
	Color.prototype.__ks_init_1 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_1();
		this._rouge = 0;
		this._vert = 0;
		this._blue = 0;
	};
	Color.prototype.__ks_func_rouge_rt = function(that, proto, args) {
		const t0 = Type.isValue;
		if(args.length === 0) {
			return proto.__ks_func_rouge_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_rouge_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Color.prototype.rouge = function() {
		return this.__ks_func_rouge_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_vert_rt = function(that, proto, args) {
		const t0 = Type.isValue;
		if(args.length === 0) {
			return proto.__ks_func_vert_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_vert_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Color.prototype.vert = function() {
		return this.__ks_func_vert_rt.call(null, this, this, arguments);
	};
	return {
		Color
	};
};