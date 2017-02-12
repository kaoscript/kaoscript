module.exports = function() {
	function foo(__ks_class_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_class_1 === void 0 || __ks_class_1 === null) {
			throw new TypeError("'class' is not nullable");
		}
		console.log(__ks_class_1);
	}
}