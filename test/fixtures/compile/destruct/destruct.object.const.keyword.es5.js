module.exports = function() {
	function foobar(data) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		var __ks_class_1 = data.class, f4 = data.for;
	}
};