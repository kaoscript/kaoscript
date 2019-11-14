module.exports = function() {
	function foobar(x, y, z, foo, bar, qux) {
		if(arguments.length < 6) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 6)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		if(foo === void 0 || foo === null) {
			throw new TypeError("'foo' is not nullable");
		}
		if(bar === void 0 || bar === null) {
			throw new TypeError("'bar' is not nullable");
		}
		if(qux === void 0 || qux === null) {
			throw new TypeError("'qux' is not nullable");
		}
		if(x === true) {
			if(foo === true) {
			}
			else if(bar === true) {
			}
			else if(qux === true) {
			}
			else {
			}
		}
		else if(y === true) {
		}
		else if(z === true) {
			if(foo === true) {
			}
			else if(bar === true) {
			}
			else if(qux === true) {
			}
			else {
			}
		}
		else {
			if(foo === true) {
			}
			else if(bar === true) {
			}
			else if(qux === true) {
			}
			else {
			}
		}
	}
};