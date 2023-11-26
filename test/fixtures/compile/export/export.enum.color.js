const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, "Red", 0, "Green", 1, "Blue", 2);
	return {
		Color
	};
};