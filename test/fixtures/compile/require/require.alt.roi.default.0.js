require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const PI = 3.14;
	var Shape = require("../export/.export.class.default.ks.j5k8r9.ksb")().Shape;
	Shape.prototype.__ks_func_color_0 = function() {
		return this._color;
	};
	Shape.prototype.__ks_func_color_1 = function(color) {
		this._color = color;
		return this;
	};
	Shape.prototype.__ks_func_color_rt = function(that, proto, args) {
		const t0 = Type.isString;
		if(args.length === 0) {
			return proto.__ks_func_color_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_color_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Shape.prototype.color = function() {
		return this.__ks_func_color_rt.call(null, this, this, arguments);
	};
	return {
		Shape
	};
};