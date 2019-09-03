module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0) {
			x = null;
		}
		if(y === void 0) {
			y = null;
		}
		if((x === null) || (y === null)) {
			return null;
		}
		return x.foobar() + y.foobar();
	}
};