require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	function toInt(n) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(n === void 0 || n === null) {
			throw new TypeError("'n' is not nullable");
		}
		else if(!Type.isNumber(n)) {
			throw new TypeError("'n' is not of type 'float'");
		}
		return __ks_Number._im_toInt(n);
	}
	return {
		toInt: toInt
	};
};