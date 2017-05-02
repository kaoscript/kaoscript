require("kaoscript/register");
module.exports = function() {
	var {Math, __ks_Math} = require("./export.sealed.namespace.ks")();
	__ks_Math.pi = function() {
		return 42;
	};
	console.log(__ks_Math.pi());
}