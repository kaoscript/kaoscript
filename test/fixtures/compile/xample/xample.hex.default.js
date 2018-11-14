require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("../_/_number.ks")();
	function hex(n) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(n === void 0 || n === null) {
			throw new TypeError("'n' is not nullable");
		}
		else if(!(Type.isString(n) || Type.isNumber(n))) {
			throw new TypeError("'n' is not of type 'String' or 'Number'");
		}
		return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 255));
	}
	console.log(hex(128));
};