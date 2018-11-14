require("kaoscript/register");
module.exports = function() {
	var name = require("../export/export.default.ks")().name;
	function foo() {
		let name = "foobar";
	}
};