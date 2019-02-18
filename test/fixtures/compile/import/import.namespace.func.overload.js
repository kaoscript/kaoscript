require("kaoscript/register");
module.exports = function() {
	var Util = require("../namespace/namespace.func.overload.ks")().Util;
	const foo = Util.reverse("hello");
	console.log(foo);
	return {
		Util: Util
	};
};