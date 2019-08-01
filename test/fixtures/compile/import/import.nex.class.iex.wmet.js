require("kaoscript/register");
module.exports = function() {
	var Foobar = require("../export/export.nex.class.iex.ks")().Foobar;
	console.log((new Foobar()).foobar());
};