require("kaoscript/register");
module.exports = function() {
	var NS = require("../export/export.namespace.class.loop.ks")().NS;
	const foo = new NS.Foobar();
	foo.name("miss White");
	console.log(foo.name());
};