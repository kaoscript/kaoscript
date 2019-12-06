var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	function foobar(lines) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(lines === void 0 || lines === null) {
			throw new TypeError("'lines' is not nullable");
		}
		else if(!Type.isArray(lines, String)) {
			throw new TypeError("'lines' is not of type 'Array<String>'");
		}
		let line = null;
		for(let i = 0, __ks_0 = lines.length; i < __ks_0; ++i) {
			if(((line = lines[i].trim()).length !== 0) || (line = true)) {
				if(line === true) {
				}
			}
		}
	}
};