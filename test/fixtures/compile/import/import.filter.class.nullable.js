require("kaoscript/register");
module.exports = function() {
	var Qux = require("../export/export.filter.class.nullable.ks")().Qux;
	const q = new Qux();
	console.log(q.foo().toString());
};