module.exports = function() {
	function foobar(foobar) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(foobar === void 0 || foobar === null) {
			throw new TypeError("'foobar' is not nullable");
		}
		return foobar;
	}
};