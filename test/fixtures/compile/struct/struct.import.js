require("kaoscript/register");
module.exports = function() {
	var Point = require("./struct.export.ks")().Point;
	const point = Point(0.3, 0.4);
	console.log(point.x + 1, point.x + point.y);
	return {
		Point: Point
	};
};