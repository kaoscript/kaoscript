var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const foo = function(a, b) {
		if(a === undefined || a === null) {
			throw new Error("Missing parameter 'a'");
		}
		else if(!Type.isNumber(a)) {
			throw new Error("Invalid type for parameter 'a'");
		}
		if(b === undefined || b === null) {
			throw new Error("Missing parameter 'b'");
		}
		else if(!Type.isNumber(b)) {
			throw new Error("Invalid type for parameter 'b'");
		}
		return a - b;
	};
}