var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(text) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(text === void 0 || text === null) {
			throw new TypeError("'text' is not nullable");
		}
		else if(!Type.isString(text)) {
			throw new TypeError("'text' is not of type 'String'");
		}
		let data;
		while(Type.isValue(data = quxbaz(text))) {
			console.log(data);
		}
	}
	function quxbaz(text) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(text === void 0 || text === null) {
			throw new TypeError("'text' is not nullable");
		}
		else if(!Type.isString(text)) {
			throw new TypeError("'text' is not of type 'String'");
		}
		return text;
	}
};