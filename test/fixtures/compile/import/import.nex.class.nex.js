require("kaoscript/register");
module.exports = function() {
	var Foobar = require("../export/export.nex.class.nex.ks")().Foobar;
	console.log((new Foobar()).quxbaz());
};