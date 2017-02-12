module.exports = function() {
	var {String, __ks_String} = require("./_string")();
	function lines(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return __ks_String._im_lines(value);
	}
}