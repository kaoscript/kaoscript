const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let coord = Helper.namespace(function() {
		let x = null, y = null, z = null;
		return {
			x,
			y,
			z
		};
	});
};