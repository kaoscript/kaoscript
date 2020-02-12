var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Point = Helper.tuple(function(x, y, z) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		if(z === void 0 || z === null) {
			z = 0;
		}
		else if(!Type.isNumber(z)) {
			throw new TypeError("'z' is not of type 'Number'");
		}
		return [x, y, z];
	});
	const point = Point(0, 0, null);
};