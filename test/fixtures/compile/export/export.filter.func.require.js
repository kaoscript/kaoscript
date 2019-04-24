var Type = require("@kaoscript/runtime").Type;
module.exports = function(Foobar) {
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
				else if(!Type.is(x, Foobar)) {
					throw new TypeError("'x' is not of type 'Foobar'");
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