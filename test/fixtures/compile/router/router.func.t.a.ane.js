var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length === 1 && Type.isClassInstance(arguments[0], Date)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isClassInstance(x, Date)) {
				throw new TypeError("'x' is not of type 'Date'");
			}
		}
		else if(arguments.length === 1 && Type.isValue(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0) {
				x = null;
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};