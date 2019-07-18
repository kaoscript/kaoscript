var Type = require("@kaoscript/runtime").Type;
module.exports = function(Space, Color) {
	Color.prototype.__ks_func_luma_0 = function() {
		return this._luma;
	};
	Color.prototype.__ks_func_luma_1 = function(luma) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
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
	Color.prototype.luma = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_luma_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_luma_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Color: Color,
		Space: Space
	};
};