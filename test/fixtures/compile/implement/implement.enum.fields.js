const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, "Red", 0, "Green", 1, "Blue", 2);
	console.log(Color.Red);
	Helper.implEnum(Color, "DarkRed", 3, "DarkGreen", 4, "DarkBlue", 5);
	console.log(Color.DarkGreen);
	return {
		Color
	};
};