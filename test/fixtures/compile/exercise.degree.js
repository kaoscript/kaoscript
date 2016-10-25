var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("./_number.ks")();
	var {String, __ks_String} = require("./_string.ks")();
	function degree(value) {
		if(value === undefined || value === null) {
			throw new Error("Missing parameter 'value'");
		}
		if(!(Type.isNumber(value) || Type.isString(value))) {
			throw new Error("Invalid type for parameter 'value'");
		}
		return __ks_Number._im_mod(Type.isNumber(value) ? __ks_Number._im_toInt(value) : __ks_String._im_toInt(value), 360);
	}
}