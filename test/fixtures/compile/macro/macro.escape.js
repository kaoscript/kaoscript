module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if((x.length === 1) || (x.length === 2) || (x.length === 3) || (x.length === 4)) {
		}
	}
};