module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
	}
	function quzbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		if(test()) {
			x = 24;
		}
		else {
			x = 42;
		}
		foobar(x);
	}
};