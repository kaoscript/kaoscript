module.exports = function() {
	const foobar = function(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		throw new Error();
	};
	return {
		foobar: foobar
	};
};