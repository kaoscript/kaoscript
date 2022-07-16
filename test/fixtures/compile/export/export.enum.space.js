const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Space = Helper.enum(String, {
		RGB: "rgb",
		SRGB: "srgb"
	});
	return {
		Space
	};
};