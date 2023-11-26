const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(String, 0, "Red", "red", "Green", "green", "Blue", "blue");
	const color = Color("red");
};