module.exports = function() {
	function surround() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let value = arguments[++__ks_i];
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		let __ks__;
		let separator = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "";
		return (separator + value + separator).toString();
	}
}