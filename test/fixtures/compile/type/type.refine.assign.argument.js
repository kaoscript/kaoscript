require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = require("../_/_array.ks")().__ks_Array;
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(Type.isArray(x)) {
			console.log(__ks_Array._im_last(x));
			if(qux(x = __ks_Array._im_last(x)) === true) {
				console.log(x.last());
			}
			else {
				console.log(x.last());
			}
		}
		else {
			console.log(x.last());
		}
	}
};