require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.nex.function.iex.ks")().foobar;
	console.log(foobar());
};