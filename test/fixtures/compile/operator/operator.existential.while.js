var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_RegExp = {};
	function foobar(text, pattern) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(text === void 0 || text === null) {
			throw new TypeError("'text' is not nullable");
		}
		else if(!Type.isString(text)) {
			throw new TypeError("'text' is not of type 'String'");
		}
		if(pattern === void 0 || pattern === null) {
			throw new TypeError("'pattern' is not nullable");
		}
		else if(!Type.isRegExp(pattern)) {
			throw new TypeError("'pattern' is not of type 'RegExp'");
		}
		let founds = [];
		let data = null;
		let __ks_0;
		while(Type.isValue(__ks_0 = pattern.exec(text)) ? (data = __ks_0, true) : false) {
			founds.push(data);
		}
	}
};