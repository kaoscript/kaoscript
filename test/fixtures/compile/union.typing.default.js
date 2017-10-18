require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("./_number.ks")();
	var {String, __ks_String} = require("./_string.ks")();
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
		if(Type.isString(x)) {
			return __ks_String._im_lower(x);
		}
		else {
			return x;
		}
	}
};