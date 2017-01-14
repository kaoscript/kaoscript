require("kaoscript/register");
module.exports = function() {
	var {String, __ks_String} = require("./_string.ks")();
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lower(foo));
}