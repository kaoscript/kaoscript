var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let Float = (function() {
		function toString(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isNumber(value)) {
				throw new TypeError("'value' is not of type 'Number'");
			}
			return value.toString();
		}
		return {
			toString: toString
		};
	})();
	console.log(Float.toString(3.14));
}