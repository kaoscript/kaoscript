var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var {String, __ks_String} = require("./_string")();
	function foo() {
		return ["1", "8", "F"];
	}
	let items = Helper.mapArray(foo(), (item) => {
		return __ks_String._im_toInt(item, 16);
	});
}