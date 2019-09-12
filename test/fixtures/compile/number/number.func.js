var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function ratio(min, max) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(min === void 0 || min === null) {
			throw new TypeError("'min' is not nullable");
		}
		else if(!Type.isNumber(min)) {
			throw new TypeError("'min' is not of type 'Number'");
		}
		if(max === void 0 || max === null) {
			throw new TypeError("'max' is not nullable");
		}
		else if(!Type.isNumber(max)) {
			throw new TypeError("'max' is not of type 'Number'");
		}
		return ((min + max) / 2).round(2);
	}
};