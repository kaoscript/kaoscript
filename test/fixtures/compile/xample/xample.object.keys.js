require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Array, __ks_Array} = require("../_/_array.ks")();
	var __ks_Object = {};
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isObject(x)) {
			throw new TypeError("'x' is not of type 'Object'");
		}
		return __ks_Array._im_last(Object.keys(x));
	}
};