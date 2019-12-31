require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(Type.isString(x) && (__ks_String._im_toInt(x) === 42)) {
			console.log(x);
		}
		else {
			console.log("" + x);
		}
	}
};