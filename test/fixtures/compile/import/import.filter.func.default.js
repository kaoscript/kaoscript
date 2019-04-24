require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.filter.func.default.ks")().foobar;
	console.log(foobar("foobar"));
};