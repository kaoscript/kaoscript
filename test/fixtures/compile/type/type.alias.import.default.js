require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	var __ks_String = require("../_/_string.ks")().__ks_String;
	let n = 0;
	console.log(__ks_Number._im_toInt(n));
	let s = "";
	console.log(__ks_String._im_toInt(s));
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x) && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'T'");
		}
		console.log(Type.isNumber(x) ? __ks_Number._im_toInt(x) : __ks_String._im_toInt(x));
	}
	n = "";
	console.log(__ks_String._im_toInt(n));
	n = 42;
	console.log(__ks_Number._im_toInt(n));
	function qux() {
		return 42;
	}
	n = qux();
	console.log(Type.isNumber(n) ? __ks_Number._im_toInt(n) : __ks_String._im_toInt(n));
};