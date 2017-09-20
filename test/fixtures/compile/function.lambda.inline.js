var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function camelize(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isString(value)) {
			throw new TypeError("'value' is not of type 'String'");
		}
		return value.charAt(0).toLowerCase() + value.substring(1).replace(/[-_\s]+(.)/g, function(m, l) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(m === void 0 || m === null) {
				throw new TypeError("'m' is not nullable");
			}
			if(l === void 0 || l === null) {
				throw new TypeError("'l' is not nullable");
			}
			return l.toUpperCase();
		});
	}
};