require("kaoscript/register");
var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var {Array, __ks_Array} = require("../_/_array.ks")();
	var __ks_Object = {};
	let item = new Dictionary();
	__ks_Array._im_last(Object.keys(item));
};