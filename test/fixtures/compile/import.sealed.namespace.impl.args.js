require("kaoscript/register");
module.exports = function() {
	var {console, Math, __ks_Math} = require("./export.sealed.namespace.impl.args.ks")();
	console.log(__ks_Math.foo(1, 0));
	console.log(__ks_Math.foo(1, null, 5));
};