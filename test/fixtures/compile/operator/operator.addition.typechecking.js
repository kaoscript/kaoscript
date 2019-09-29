var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(parameters, index) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(parameters === void 0 || parameters === null) {
			throw new TypeError("'parameters' is not nullable");
		}
		if(index === void 0 || index === null) {
			throw new TypeError("'index' is not nullable");
		}
		if(Type.isNumber(parameters[index])) {
			index = parameters[index] + 1;
		}
	}
};