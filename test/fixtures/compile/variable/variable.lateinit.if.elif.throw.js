module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		let z = null;
		if(x === 0) {
			z = 1;
		}
		else if(y === 0) {
			throw new Error();
		}
		else if((x === 1) && (y === 1)) {
			z = 2;
		}
		else {
			z = 0;
		}
		return z;
	}
};