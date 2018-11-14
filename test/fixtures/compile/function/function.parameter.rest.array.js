require("kaoscript/register");
module.exports = function() {
	var {Array, __ks_Array} = require("../_/_array.ks")();
	function foo(...items) {
		console.log(__ks_Array._im_last(items));
	}
};