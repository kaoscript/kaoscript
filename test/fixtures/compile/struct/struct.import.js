require("kaoscript/register");
module.exports = function() {
	var Point = require("./.struct.export.ks.j5k8r9.ksb")().Point;
	const point = Point.__ks_new(0.3, 0.4);
	console.log(point.x + 1, point.x + point.y);
	return {
		Point
	};
};