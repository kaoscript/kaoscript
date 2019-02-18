require("kaoscript/register");
module.exports = function() {
	var NS = require("../export/export.namespace.default.ks")().NS;
	console.log(NS.foo());
	return {
		NS: NS
	};
};