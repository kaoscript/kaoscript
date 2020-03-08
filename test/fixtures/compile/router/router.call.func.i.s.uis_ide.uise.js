var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x) && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'Number' or 'String'");
		}
		return quxbaz(x);
	}
	function quxbaz() {
		if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return 1;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return 2;
		}
		else if(arguments.length === 2) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x) && !Type.isString(x)) {
				throw new TypeError("'x' is not of type 'Number' or 'String'");
			}
			let y;
			if(arguments.length > 1 && (y = arguments[++__ks_i]) !== void 0 && y !== null) {
				if(!Type.isNumber(y)) {
					throw new TypeError("'y' is not of type 'Number'");
				}
			}
			else {
				y = 0;
			}
			return "3";
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};