require("kaoscript/register");
module.exports = function() {
	var NS = require("../export/export.namespace.enum.ks")().NS;
	console.log(NS.foo());
};