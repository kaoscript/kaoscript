require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foobar() {
		let x = null, y = null;
		if(quxbaz(x = "foobar") || quxbaz(x = 42)) {
			console.log(Type.isString(x) ? __ks_String._im_toInt(x) : __ks_Number._im_toInt(x));
			console.log(y.toInt());
		}
		console.log(Type.isString(x) ? __ks_String._im_toInt(x) : __ks_Number._im_toInt(x));
		console.log(y.toInt());
	}
	function quxbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		return true;
	}
};