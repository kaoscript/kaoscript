require("kaoscript/register");
module.exports = function() {
	var NS = require("../export/export.nex.namespace.nex.ks")().NS;
	console.log(NS.quxbaz());
};