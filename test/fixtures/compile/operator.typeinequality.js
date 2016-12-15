var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function isNotString(value = null) {
		return !Type.isString(value);
	}
}