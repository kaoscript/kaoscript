var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let coord = Helper.namespace(function() {
		let x = null, y = null, z = null;
		return {
			x: x,
			y: y,
			z: z
		};
	});
};