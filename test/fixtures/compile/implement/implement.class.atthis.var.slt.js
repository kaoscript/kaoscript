require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Shape = require("../export/.export.class.default.ks.j5k8r9.ksb")().Shape;
	Shape.prototype.__ks_func_draw_0 = function(canvas) {
		return "I'm drawing a " + this._color + " rectangle.";
	};
	Shape.prototype.__ks_func_draw_rt = function(that, proto, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_draw_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Shape.prototype.draw = function() {
		return this.__ks_func_draw_rt.call(null, this, this, arguments);
	};
};