module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let value = null;
		if(x === 1 || x === 2 || x === 3) {
			value = 0;
		}
		else if(x === 4) {
			value = 1;
		}
		else {
			value = -1;
		}
		return value;
	}
};