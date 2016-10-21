var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var Float = require("./_float.ks")().Float;
	var {Number, __ks_Number} = require("./_number.ks")();
	function hex(n) {
		if(n === undefined || n === null) {
			throw new Error("Missing parameter 'n'");
		}
		if(!(Type.isString(n) || Type.isNumber(n))) {
			throw new Error("Invalid type for parameter 'n'");
		}
		return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 255));
	}
	console.log(hex(128));
}