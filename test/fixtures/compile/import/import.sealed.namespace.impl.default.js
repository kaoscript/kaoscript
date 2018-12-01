require("kaoscript/register");
module.exports = function() {
	var {console, Number, __ks_Number, Math, __ks_Math} = require("../export/export.sealed.namespace.impl.default.ks")();
	console.log("" + Math.PI);
	console.log("" + __ks_Math.pi);
	console.log("" + __ks_Math.foo());
	console.log(Math.PI.toString());
	console.log(__ks_Math.pi.toString());
	console.log(__ks_Math.foo().toString());
};