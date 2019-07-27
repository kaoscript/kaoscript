module.exports = function() {
	function foo(bar) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(bar === void 0 || bar === null) {
			throw new TypeError("'bar' is not nullable");
		}
		let qux = Array.prototype.slice.call(arguments, 1, arguments.length);
	}
};