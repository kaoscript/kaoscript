var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Point = Helper.struct(function(x, y) {
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
		const _ = new Dictionary();
		_.x = x;
		_.y = y;
		return _;
	});
	var Point3D = Helper.struct(function(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		else if(!Type.isNumber(z)) {
			throw new TypeError("'z' is not of type 'Number'");
		}
		const _ = Point.__ks_builder(x, y);
		_.z = z;
		return _;
	}, Point);
	let point = Point3D(0.3, 0.4, 0.5);
	console.log(point.x + 1, point.y + 2, point.z + 3);
	return {
		Point: Point,
		Point3D: Point3D
	};
};