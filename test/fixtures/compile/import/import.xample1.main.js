require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Date = require("./import.xample1.core.ks")().__ks_Date;
	var __ks_Date = require("./import.xample1.extra.ks")(__ks_Date).__ks_Date;
	function foobar(d) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		else if(!Type.isClassInstance(d, Date)) {
			throw new TypeError("'d' is not of type 'Date'");
		}
		const t = __ks_Date._im_getEpochTime(d);
	}
};