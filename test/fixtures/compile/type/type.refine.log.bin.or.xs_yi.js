require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Boolean = require("../_/_boolean.ks")().__ks_Boolean;
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function test(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		return true;
	}
	function foobar() {
		let x = false;
		let y = false;
		if(test(x = "1") || test(y = 2)) {
			console.log(__ks_String._im_toInt(x));
			console.log(Type.isBoolean(y) ? __ks_Boolean._im_toInt(y) : __ks_Number._im_toInt(y));
		}
		else {
			console.log(__ks_String._im_toInt(x));
			console.log(Type.isBoolean(y) ? __ks_Boolean._im_toInt(y) : __ks_Number._im_toInt(y));
		}
		console.log(__ks_String._im_toInt(x));
		console.log(Type.isBoolean(y) ? __ks_Boolean._im_toInt(y) : __ks_Number._im_toInt(y));
	}
};