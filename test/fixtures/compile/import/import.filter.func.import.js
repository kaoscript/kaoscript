require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.filter.func.import.ks")().foobar;
	console.log(foobar("foobar"));
};