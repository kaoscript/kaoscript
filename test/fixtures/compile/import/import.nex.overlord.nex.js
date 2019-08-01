require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.nex.overlord.nex.ks")().foobar;
	console.log(foobar("foobar"));
};