require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	function blend(x, y, percentage) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'float'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'float'");
		}
		if(percentage === void 0 || percentage === null) {
			throw new TypeError("'percentage' is not nullable");
		}
		else if(!Type.isNumber(percentage)) {
			throw new TypeError("'percentage' is not of type 'float'");
		}
		return ((1 - percentage) * x) + (percentage * y);
	}
	console.log(__ks_Number._im_round(blend(0.8, 0.5, 0.3), 2));
};