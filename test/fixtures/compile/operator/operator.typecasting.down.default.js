require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var {String, __ks_String} = require("../_/_string.ks")();
	function lines(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return __ks_String._im_lines(Helper.cast(value, "String", false, null, "String"));
	}
};