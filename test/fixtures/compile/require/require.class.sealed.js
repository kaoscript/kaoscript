var {initFlag, Type} = require("@kaoscript/runtime");
module.exports = function(Color, __ks_Color) {
	__ks_Color.__ks_init_0 = function(that) {
		that._luma = 0;
	};
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
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(luma === void 0 || luma === null) {
			throw new TypeError("'luma' is not nullable");
		}
		else if(!Type.isNumber(luma)) {
			throw new TypeError("'luma' is not of type 'Number'");
		}
		__ks_Color.__ks_set_luma(this, luma);
		return this;
	};
	__ks_Color.__ks_init = function(that) {
		__ks_Color.__ks_init_0(that);
		that[initFlag] = true;
	};
	__ks_Color._im_luma = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Color.__ks_func_luma_0.apply(that);
		}
		else if(args.length === 1) {
			return __ks_Color.__ks_func_luma_1.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Color: Color,
		__ks_Color: __ks_Color
	};
};