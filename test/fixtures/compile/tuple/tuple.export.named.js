var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.tuple(function() {
		let __ks_i = -1;
		let x;
		if(arguments.length > ++__ks_i && (x = arguments[__ks_i]) !== void 0 && x !== null) {
			if(!Type.isString(x)) {
				if(arguments.length - __ks_i < 2) {
					x = "";
					--__ks_i;
				}
				else {
					throw new TypeError("'x' is not of type 'String'");
				}
			}
		}
		else {
			x = "";
		}
		let y;
		if(arguments.length > ++__ks_i && (y = arguments[__ks_i]) !== void 0 && y !== null) {
			if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
		}
		else {
			y = 0;
		}
		return [x, y];
	});
	return {
		Pair: Pair
	};
};