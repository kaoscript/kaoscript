var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(x === undefined || x === null) {
			x = "jane";
		}
		if(true) {
			var __ks_x_1 = "john";
			console.log(Type.isValue(__ks_x_1.toUpperCase));
		}
	}
}