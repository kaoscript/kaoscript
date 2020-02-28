var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isArray(values, String)) {
			throw new TypeError("'values' is not of type 'Array<String>'");
		}
		for(let i = 1; i <= 10; ++i) {
			if(Type.isValue(values[i])) {
			}
		}
	}
};