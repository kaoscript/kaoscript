require("kaoscript/register");
module.exports = function() {
	var {console, Number, __ks_Number, Math, __ks_Math} = require("./export.sealed.namespace.impl.default.ks")();
	console.log("" + Math.pi);
	console.log("" + __ks_Math.foo());
	console.log(Math.pi.toString());
	console.log(__ks_Math.foo().toString());
};