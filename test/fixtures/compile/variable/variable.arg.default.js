module.exports = function() {
	function foo(foo) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(foo === void 0 || foo === null) {
			throw new TypeError("'foo' is not nullable");
		}
	}
	function bar() {
		return 42;
	}
	let x;
	foo(x = bar());
};