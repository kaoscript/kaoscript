var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length === 1 && Type.isArray(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isArray(x)) {
				throw new TypeError("'x' is not of type 'Array'");
			}
			return x;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0) {
				x = null;
			}
			return x;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};