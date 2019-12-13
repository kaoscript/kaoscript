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
	function foobar(p) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(p === void 0 || p === null) {
			throw new TypeError("'p' is not nullable");
		}
		else if(!Type.isStructInstance(p, Point)) {
			throw new TypeError("'p' is not of type 'Point'");
		}
		const d3 = Helper.cast(p, "Point3D", true, Point3D, "Struct");
		if(d3 !== null) {
			console.log(d3.x + 1, d3.y + 2, d3.z + 3);
		}
	}
};