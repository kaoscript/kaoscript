module.exports = function() {
	function foo(__ks_static_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_static_1 === void 0 || __ks_static_1 === null) {
			throw new TypeError("'static' is not nullable");
		}
		console.log(__ks_static_1);
	}
};