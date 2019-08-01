require("kaoscript/register");
module.exports = function() {
	var NS = require("../export/export.nex.namespace.iex.ks")().NS;
	console.log(NS.foobar());
};