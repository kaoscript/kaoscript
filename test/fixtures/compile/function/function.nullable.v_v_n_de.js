var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		let __ks_i = -1;
		let x = arguments[++__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let y = arguments[++__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		let z = arguments[++__ks_i];
		if(z === void 0) {
			z = null;
		}
		else if(z !== null && !Type.isString(z)) {
			throw new TypeError("'z' is not of type 'String'");
		}
		let __ks__;
		let d = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 42;
	}
	foobar(42, 24, null);
};