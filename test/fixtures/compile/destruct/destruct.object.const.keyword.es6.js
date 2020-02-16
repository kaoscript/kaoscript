module.exports = function() {
	function foobar(data) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		const {class: __ks_class_1, for: f4} = data;
	}
};