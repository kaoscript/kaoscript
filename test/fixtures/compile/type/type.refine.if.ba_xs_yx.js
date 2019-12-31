require("kaoscript/register");
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	var __ks_String = require("../_/_string.ks")().__ks_String;
	function foobar() {
		let x = null, y = null;
		if(quxbaz(x = "foobar") && quxbaz(y = x)) {
			console.log(__ks_String._im_toInt(x));
			console.log(__ks_String._im_toInt(y));
		}
		console.log(__ks_String._im_toInt(x));
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