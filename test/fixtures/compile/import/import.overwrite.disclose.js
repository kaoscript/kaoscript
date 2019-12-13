require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Date, __ks_Date} = require("../implement/implement.overwrite.disclose.ks")();
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
	}
	const d = new Date();
	foobar(__ks_Date._im_setDate(d, 1));
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};