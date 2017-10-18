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
		return 42 - (Type.isNumber(x) ? __ks_String._im_toFloat(x) : __ks_Number._im_toFloat(x));
	}
	function bar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!(Type.isString(x) || Type.isNumber(x))) {
			throw new TypeError("'x' is not of type 'String' or 'Number'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!(Type.isString(y) || Type.isNumber(y))) {
			throw new TypeError("'y' is not of type 'String' or 'Number'");
		}
		return (Type.isNumber(x) ? __ks_String._im_toFloat(x) : __ks_Number._im_toFloat(x)) - (Type.isNumber(y) ? __ks_String._im_toFloat(y) : __ks_Number._im_toFloat(y));
	}
};