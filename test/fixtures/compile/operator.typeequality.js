var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function isString(value = null) {
		return Type.isString(value);
	}
}