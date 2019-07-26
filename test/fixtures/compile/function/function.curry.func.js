var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Function = {};
	let fn = function(prefix, name) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(prefix === void 0 || prefix === null) {
			throw new TypeError("'prefix' is not nullable");
		}
		else if(!Type.isString(prefix)) {
			throw new TypeError("'prefix' is not of type 'String'");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		return prefix + name;
	};
	fn = Function.curry(fn, "Hello ");
	console.log("" + fn("White"));
};