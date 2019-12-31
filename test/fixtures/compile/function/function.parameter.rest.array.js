require("kaoscript/register");
module.exports = function() {
	var __ks_Array = require("../_/_array.ks")().__ks_Array;
	function foo(...items) {
		console.log(__ks_Array._im_last(items));
	}
};