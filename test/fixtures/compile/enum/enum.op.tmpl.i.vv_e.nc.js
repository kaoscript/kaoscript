const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
	const color = Color.Red;
	const value = Helper.toString(color);
};