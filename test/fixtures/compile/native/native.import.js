require("kaoscript/register");
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lower(foo));
};