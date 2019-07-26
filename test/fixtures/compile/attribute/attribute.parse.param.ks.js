module.exports = function() {
	function foo(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			y = 1;
		}
		let __ks_i;
		let args = arguments.length > 3 ? Array.prototype.slice.call(arguments, 2, __ks_i = arguments.length - 1) : (__ks_i = 2, []);
		let z = arguments[__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(x, y, args, z);
	}
};