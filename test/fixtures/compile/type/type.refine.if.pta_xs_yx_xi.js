module.exports = function() {
	function foobar() {
		let x = null, y = null;
		if(quxbaz(x = "foobar") && quxbaz(y = x) && quxbaz(x = 42)) {
			console.log("" + x);
			console.log(y);
		}
		console.log("" + x);
		console.log("" + y);
	}
	function quxbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		return true;
	}
};