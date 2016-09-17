var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
		if(!Type.isArray(bar, String)) {
			throw new Error("Invalid type for parameter 'bar'");
		}
	}
}