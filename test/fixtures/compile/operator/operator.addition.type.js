module.exports = function() {
	function surround(value, separator) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		if(separator === void 0 || separator === null) {
			separator = "";
		}
		return (separator + value + separator).toString();
	}
};