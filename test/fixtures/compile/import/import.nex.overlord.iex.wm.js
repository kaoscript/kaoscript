require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.nex.overlord.iex.ks")().foobar;
	console.log(foobar());
};