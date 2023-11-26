const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Space = Helper.enum(String, 0, "RGB", "rgb", "SRGB", "srgb");
	return {
		Space
	};
};