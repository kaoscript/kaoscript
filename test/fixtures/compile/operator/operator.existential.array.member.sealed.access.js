require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isArray(values, String)) {
			throw new TypeError("'values' is not of type 'Array<String>'");
		}
		return Type.isValue(values[0]) ? values[0].toInt : null;
	}
};