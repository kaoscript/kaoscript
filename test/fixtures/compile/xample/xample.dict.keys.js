require("kaoscript/register");
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Array, __ks_Array} = require("../_/_array.ks")();
	var __ks_Dictionary = {};
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isDictionary(x)) {
			throw new TypeError("'x' is not of type 'Dictionary'");
		}
		return __ks_Array._im_last(Dictionary.keys(x));
	}
};