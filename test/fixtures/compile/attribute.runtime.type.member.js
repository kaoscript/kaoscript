var Type = require("@kaoscript/runtime").yourtype;
module.exports = function() {
	function foo(x, y) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			throw new Error("Missing parameter 'y'");
		}
		if(Type.isString(x)) {
			return x.toInt();
		}
		else {
			return y;
		}
	}
}