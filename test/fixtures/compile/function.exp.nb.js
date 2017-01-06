var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const foo = function(a, b) {
		if(a === undefined || a === null) {
			throw new Error("Missing parameter 'a'");
		}
		if(!Type.isNumber(a)) {
			throw new Error("Invalid type for parameter 'a'");
		}
		if(b === undefined || b === null) {
			throw new Error("Missing parameter 'b'");
		}
		if(!Type.isNumber(b)) {
			throw new Error("Invalid type for parameter 'b'");
		}
		return a - b;
	};
}