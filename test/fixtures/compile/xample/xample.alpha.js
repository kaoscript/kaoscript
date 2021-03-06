require("kaoscript/register");
module.exports = function() {
	var Float = require("../_/_float.ks")().Float;
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	function alpha(n = null, percentage) {
		if(percentage === void 0 || percentage === null) {
			percentage = false;
		}
		let i = Float.parse(n);
		return Number.isNaN(i) ? 1 : __ks_Number._im_round(__ks_Number._im_limit((percentage === true) ? i / 100 : i, 0, 1), 3);
	}
};