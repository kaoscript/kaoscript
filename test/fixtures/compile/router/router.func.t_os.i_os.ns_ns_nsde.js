var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function __ks_foobar_0(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isClassInstance(x, Date)) {
			throw new TypeError("'x' is not of type 'Date'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isDictionary(y) && !Type.isString(y)) {
			throw new TypeError("'y' is not of type 'Dictionary' or 'String'");
		}
		return 0;
	}
	function __ks_foobar_1(x, y) {
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
		else if(!Type.isDictionary(y) && !Type.isString(y)) {
			throw new TypeError("'y' is not of type 'Dictionary' or 'String'");
		}
		return 1;
	}
	function __ks_foobar_2(x, y, z) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x) && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'Number' or 'String'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y) && !Type.isString(y)) {
			throw new TypeError("'y' is not of type 'Number' or 'String'");
		}
		if(z === void 0 || z === null) {
			z = 0;
		}
		else if(!Type.isNumber(z) && !Type.isString(z)) {
			throw new TypeError("'z' is not of type 'Number' or 'String'");
		}
		return 2;
	}
	function foobar() {
		if(arguments.length === 2) {
			if(Type.isClassInstance(arguments[0], Date)) {
				return __ks_foobar_0(...arguments);
			}
			else if(Type.isNumber(arguments[0]) && Type.isNumber(arguments[1])) {
				return __ks_foobar_2(...arguments);
			}
			else if(Type.isNumber(arguments[0])) {
				return __ks_foobar_1(...arguments);
			}
			else {
				return __ks_foobar_2(...arguments);
			}
		}
		else if(arguments.length === 3) {
			return __ks_foobar_2(...arguments);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};