require("kaoscript/register");
module.exports = function() {
	var reverse = require("./function.overloading.export.ks")().reverse;
	const foo = reverse("hello");
	console.log(foo);
};