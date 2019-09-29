var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		function toFloat(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isString(value)) {
				throw new TypeError("'value' is not of type 'String'");
			}
			return parseFloat(value);
		}
		function toString(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			toFloat: toFloat,
			toString: toString
		};
	});
	return {
		Float: Float
	};
};