var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(date) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(date === void 0 || date === null) {
			throw new TypeError("'date' is not nullable");
		}
		else if(!Type.isClassInstance(date, Date)) {
			throw new TypeError("'date' is not of type 'Date'");
		}
		return ("" + date.getFullYear()).substring(-2);
	}
};