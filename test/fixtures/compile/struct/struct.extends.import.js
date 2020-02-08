require("kaoscript/register");
module.exports = function() {
	var {Point, Point3D} = require("./struct.extends.default.ks")();
	let point = Point3D(0.3, 0.4, 0.5);
	console.log(point.x + 1, point.y + 2, point.z + 3);
};