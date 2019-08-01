require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.nex.function.nex.na.ks")().foobar;
	console.log(foobar("foobar"));
};