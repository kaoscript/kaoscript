var Type = require("@kaoscript/runtime").Type;
module.exports = function(Color, __ks_Color) {
	__ks_Color.__ks_func_luma_0 = function() {
		return this._luma;
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
		this._luma = luma;
		return this;
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