module.exports = function() {
	var __ks_Math = {};
	__ks_Math.foo = function() {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let x = arguments[++__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let y = arguments[++__ks_i];
		if(y === void 0) {
			y = null;
		}
		let __ks__;
		let z = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : -1;
		return "" + x + "." + y + "." + z;
	};
	return {
		console: console,
		Math: Math,
		__ks_Math: __ks_Math
	};
}