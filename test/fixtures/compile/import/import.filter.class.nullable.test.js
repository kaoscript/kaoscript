require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var Qux = require("../export/export.filter.class.nullable.ks")().Qux;
	const q = new Qux();
	let foo = q.foo();
	if(Type.isValue(foo)) {
		console.log(foo.toString());
	}
};