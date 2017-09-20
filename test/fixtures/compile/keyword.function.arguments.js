module.exports = function() {
	function foo(__ks_arguments_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_arguments_1 === void 0 || __ks_arguments_1 === null) {
			throw new TypeError("'arguments' is not nullable");
		}
		console.log(__ks_arguments_1);
	}
};