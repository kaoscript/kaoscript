var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(foobar) {
		if(foobar === void 0 || foobar === null) {
			foobar = "foobar";
		}
		else if(!Type.isString(foobar)) {
			throw new TypeError("'foobar' is not of type 'String'");
		}
		return foobar;
	}
};