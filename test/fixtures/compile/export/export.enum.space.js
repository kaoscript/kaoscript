var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Space = Helper.enum(String, {
		RGB: "rgb",
		SRGB: "srgb"
	});
	return {
		Space: Space
	};
};