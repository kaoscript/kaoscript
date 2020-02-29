var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function __ks_foobar_0(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		return 0;
	}
	function __ks_foobar_1(x, ...args) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		return 1;
	}
	function __ks_foobar_2(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		return 2;
	}
	function __ks_foobar_3(x, ...args) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		return 3;
	}
	function foobar() {
		if(arguments.length === 2) {
			if(Type.isNumber(arguments[0]) && Type.isNumber(arguments[1])) {
				return __ks_foobar_0(...arguments);
			}
			else if(Type.isNumber(arguments[0])) {
				return __ks_foobar_1(...arguments);
			}
			else if(Type.isNumber(arguments[1])) {
				return __ks_foobar_2(...arguments);
			}
			else {
				return __ks_foobar_3(...arguments);
			}
		}
		else if(arguments.length >= 1) {
			if(Type.isNumber(arguments[0])) {
				return __ks_foobar_1(...arguments);
			}
			else if(Type.isString(arguments[0])) {
				return __ks_foobar_3(...arguments);
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};