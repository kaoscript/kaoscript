var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	function quxbaz() {
		let name = foobar();
		if(Type.isValue(name)) {
			return name;
		}
		else {
			return "quxbaz";
		}
	}
};