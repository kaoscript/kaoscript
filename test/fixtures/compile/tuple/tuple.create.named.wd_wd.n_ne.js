var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Point = Helper.tuple(function(x, y) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		return [x, y];
	});
	const point = Point();
};