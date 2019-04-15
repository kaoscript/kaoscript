var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const o = {};
	function foo(key) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(key === void 0 || key === null) {
			throw new TypeError("'key' is not nullable");
		}
		else if(!Type.isString(key)) {
			throw new TypeError("'key' is not of type 'String'");
		}
		const x = o[key];
		if(Type.isFunction(x)) {
		}
	}
};