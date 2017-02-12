require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("./_number.ks")();
	var {String, __ks_String} = require("./_string.ks")();
	function degree(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!(Type.isNumber(value) || Type.isString(value))) {
			throw new TypeError("'value' is not of type 'Number' or 'String'");
		}
		return __ks_Number._im_mod(Type.isNumber(value) ? __ks_Number._im_toInt(value) : __ks_String._im_toInt(value), 360);
	}
}