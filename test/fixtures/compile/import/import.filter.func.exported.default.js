require("kaoscript/register");
module.exports = function() {
	var {foobar, qux} = require("../export/export.filter.func.exported.default.ks")();
	console.log(qux("foobar"));
	const x = foobar();
	console.log(x.toString());
	console.log(qux(x).toString());
};