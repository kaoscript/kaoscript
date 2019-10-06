var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(data, __ks_0, name) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		if(__ks_0 !== null && !Type.isDictionary(__ks_0)) {
			throw new TypeError("anonymous argument is not of type 'Dictionary?'");
		}
		if(name === void 0 || name === null) {
			name = data.name;
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		console.log(name);
	}
};