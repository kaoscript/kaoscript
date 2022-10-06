require("kaoscript/register");
const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Color, Space} = require("../.color.ks.j5k8r9.ksb")();
	Space.RVB = Space("rvb");
	Color.__ks_sttc_registerSpace_0((() => {
		const d = new Dictionary();
		d["name"] = "rvb";
		d["converters"] = (() => {
			const d = new Dictionary();
			d["from"] = (() => {
				const d = new Dictionary();
				d.srgb = Helper.function(function(red, green, blue, that) {
					that._rouge = red;
					that._vert = green;
					that._blue = blue;
				}, (fn, ...args) => {
					const t0 = Type.isValue;
					if(args.length === 4) {
						if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3])) {
							return fn.call(null, args[0], args[1], args[2], args[3]);
						}
					}
					throw Helper.badArgs();
				});
				return d;
			})();
			d["to"] = (() => {
				const d = new Dictionary();
				d.srgb = Helper.function(function(rouge, vert, blue, that) {
					that._red = rouge;
					that._green = vert;
					that._blue = blue;
				}, (fn, ...args) => {
					const t0 = Type.isValue;
					if(args.length === 4) {
						if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3])) {
							return fn.call(null, args[0], args[1], args[2], args[3]);
						}
					}
					throw Helper.badArgs();
				});
				return d;
			})();
			return d;
		})();
		d["components"] = (() => {
			const d = new Dictionary();
			d["rouge"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			d["vert"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			d["blue"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			return d;
		})();
		return d;
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
	Color.prototype.__ks_init_4 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_4();
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