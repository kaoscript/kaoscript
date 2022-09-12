const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let coord = Helper.namespace(function() {
		let x, y, z;
		return {
			x,
			y,
			z
		};
	});
};