module.exports = function() {
	function foo(bar) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(bar === void 0 || bar === null) {
			throw new TypeError("'bar' is not nullable");
		}
	}
	function bar() {
		foo(42);
	}
};