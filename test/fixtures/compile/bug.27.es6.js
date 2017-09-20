module.exports = function() {
	function corge(foo, args) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(foo === void 0 || foo === null) {
			throw new TypeError("'foo' is not nullable");
		}
		if(args === void 0 || args === null) {
			throw new TypeError("'args' is not nullable");
		}
		foo.bar().qux(...args);
	}
};