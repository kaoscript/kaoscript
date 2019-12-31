require("kaoscript/register");
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foo() {
		return ["1", "8", "F"];
	}
	for(let __ks_0 = 0, __ks_1 = foo(), __ks_2 = __ks_1.length, item; __ks_0 < __ks_2; ++__ks_0) {
		item = __ks_1[__ks_0];
		console.log(__ks_String._im_toInt(item, 16));
	}
};