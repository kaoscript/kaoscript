var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(...args) {
		return quxbaz(...args);
	}
	function quxbaz() {
		if(arguments.length === 2 && Type.isNumber(arguments[0]) && Type.isNumber(arguments[1])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			let y = arguments[++__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			else if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
		}
		else if(arguments.length === 2) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let y = arguments[++__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};