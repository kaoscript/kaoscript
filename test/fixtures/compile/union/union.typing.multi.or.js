require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x) && !Type.isNumber(x) && !Type.isArray(x)) {
			throw new TypeError("'x' is not of type 'String', 'Number' or 'Array'");
		}
		if(Type.isString(x) || Type.isNumber(x)) {
			return Type.isString(x) ? __ks_String._im_toFloat(x) : __ks_Number._im_toFloat(x);
		}
		else {
			return x;
		}
	}
};