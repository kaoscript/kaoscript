require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("../_/_number.ks")();
	var {String, __ks_String} = require("../_/_string.ks")();
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!(Type.isString(x) || Type.isNumber(x))) {
			throw new TypeError("'x' is not of type 'String' or 'Number'");
		}
		if((Type.isString(x) ? __ks_String._im_toFloat(x) : __ks_Number._im_toFloat(x)) === 42) {
		}
	}
};