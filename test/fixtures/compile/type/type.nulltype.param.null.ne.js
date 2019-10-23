module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		else if(x !== null) {
			throw new TypeError("'x' is not of type 'Null'");
		}
	}
	foobar(null);
	return {
		foobar: foobar
	};
};