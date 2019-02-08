require("kaoscript/register");
module.exports = function() {
	var {NS, foobar} = require("../export/export.namespace.split.default.ks")();
	console.log(NS.foo());
	console.log(foobar());
};