require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {Number, __ks_Number} = require("./_number.ks")();
	function blend(x, y, percentage) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		else if(!Type.isNumber(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		if(y === undefined || y === null) {
			throw new Error("Missing parameter 'y'");
		}
		else if(!Type.isNumber(y)) {
			throw new Error("Invalid type for parameter 'y'");
		}
		if(percentage === undefined || percentage === null) {
			throw new Error("Missing parameter 'percentage'");
		}
		else if(!Type.isNumber(percentage)) {
			throw new Error("Invalid type for parameter 'percentage'");
		}
		return ((1 - percentage) * x) + (percentage * y);
	}
	console.log(__ks_Number._im_round(blend(0.8, 0.5, 0.3), 2));
}