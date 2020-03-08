var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Coord = Helper.struct(function(x, y, elevation) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
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
		if(elevation === void 0 || elevation === null) {
			throw new TypeError("'elevation' is not nullable");
		}
		else if(!Type.isDictionary(elevation) || !Type.isString(elevation.unit) || !Type.isNumber(elevation.value)) {
			throw new TypeError("'elevation' is not of type '{unit: String, value: Number}'");
		}
		const _ = new Dictionary();
		_.x = x;
		_.y = y;
		_.elevation = elevation;
		return _;
	});
	return {
		Coord: Coord
	};
};