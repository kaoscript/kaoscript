require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foo() {
		return ["1", "8", "F"];
	}
	let items = Helper.mapArray(foo(), function(item) {
		return __ks_String._im_toInt(item, 16);
	});
};