const {Helper, initFlag, Type} = require("@kaoscript/runtime");
module.exports = function(Color, __ks_Color) {
	__ks_Color.__ks_get_luma = function(that) {
		if(!that[initFlag]) {
			__ks_Color.__ks_init(that);
		}
		return that._luma;
	};
	__ks_Color.__ks_set_luma = function(that, value) {
		if(!that[initFlag]) {
			__ks_Color.__ks_init(that);
		}
		that._luma = value;
	};
	__ks_Color.__ks_func_luma_0 = function() {
		return __ks_Color.__ks_get_luma(this);
	};
	__ks_Color.__ks_func_luma_1 = function(luma) {
		__ks_Color.__ks_set_luma(this, luma);
		return this;
	};
	__ks_Color.__ks_init = function(that) {
		that._luma = 0;
		that[initFlag] = true;
	};
	__ks_Color._im_luma = function(that, ...args) {
		return __ks_Color.__ks_func_luma_rt(that, args);
	};
	__ks_Color.__ks_func_luma_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 0) {
			return __ks_Color.__ks_func_luma_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Color.__ks_func_luma_1.call(that, args[0]);
			}
		}
		if(that.luma) {
			return that.luma(...args);
		}
		throw Helper.badArgs();
	};
	return {
		Color,
		__ks_Color
	};
};