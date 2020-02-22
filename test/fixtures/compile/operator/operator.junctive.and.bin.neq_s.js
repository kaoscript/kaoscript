module.exports = function() {
	function foobar(color) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		if(color !== "black" && color !== "white") {
		}
	}
};