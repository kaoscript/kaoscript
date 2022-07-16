const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Space, Color) {
	Color.prototype.__ks_func_luma_0 = function() {
		return this._luma;
	};
	Color.prototype.__ks_func_luma_1 = function(luma) {
		this._luma = luma;
		return this;
	};
	Color.prototype.__ks_init_0 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_0();
		this._luma = 0;
	};
	Color.prototype.__ks_func_luma_rt = function(that, proto, args) {
		const t0 = Type.isNumber;
		if(args.length === 0) {
			return proto.__ks_func_luma_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_luma_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Color.prototype.luma = function() {
		return this.__ks_func_luma_rt.call(null, this, this, arguments);
	};
	return {
		Color,
		Space
	};
};