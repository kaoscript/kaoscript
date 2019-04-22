require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Function, __ks_Function} = require("../_/_function.ks")();
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
	}
	return {
		foobar: foobar
	};
};