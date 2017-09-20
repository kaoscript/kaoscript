require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("./_number.ks")();
	var {String, __ks_String} = require("./_string.ks")();
	let x = 0;
	console.log(Type.isNumber(x) ? __ks_Number._im_toInt(x) : __ks_String._im_toInt(x));
};