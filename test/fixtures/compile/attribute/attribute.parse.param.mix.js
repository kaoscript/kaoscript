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
		let __ks_i = 1;
		let args = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
		let z = arguments[__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(x, y, args, z);
	}
	function bar(x, y = 1, ...args) {
		console.log(x, y, args);
	}
	function baz(x, y) {
		console.log(x, y);
	}
	function qux(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			y = 1;
		}
		let __ks_i = 1;
		let args = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
		let z = arguments[__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(x, y, args, z);
	}
};