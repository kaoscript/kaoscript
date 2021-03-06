var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_RegExp = {};
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
	}
	const regex = /foo/;
	let match = regex.exec("foobar");
	if(Type.isValue(match)) {
		if(Type.isValue(match[0])) {
			foobar(match[0]);
		}
	}
};