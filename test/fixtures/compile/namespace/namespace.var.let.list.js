var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let coord = Helper.namespace(function() {
		let x, y, z;
		return {
			x: x,
			y: y,
			z: z
		};
	});
};