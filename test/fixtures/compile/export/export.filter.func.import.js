require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var Shape = require("../export/export.class.default.ks")().Shape;
	function foobar() {
		if(arguments.length === 1) {
			if(Type.isString(arguments[0])) {
				let __ks_i = -1;
				let x = arguments[++__ks_i];
				if(x === void 0 || x === null) {
					throw new TypeError("'x' is not nullable");
				}
				else if(!Type.isString(x)) {
					throw new TypeError("'x' is not of type 'String'");
				}
				return x;
			}
			else {
				let __ks_i = -1;
				let x = arguments[++__ks_i];
				if(x === void 0 || x === null) {
					throw new TypeError("'x' is not nullable");
				}
				else if(!Type.is(x, Shape)) {
					throw new TypeError("'x' is not of type 'Shape'");
				}
				return x;
			}
		}
		else {
			throw new SyntaxError("wrong number of arguments");
		}
	};
	return {
		foobar: foobar
	};
};