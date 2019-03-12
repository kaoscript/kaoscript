var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	function foo(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isString(value)) {
			throw new TypeError("'value' is not of type 'String'");
		}
		console.log(value.trim());
		const list = value.split(",");
		console.log(list[0]);
	}
};