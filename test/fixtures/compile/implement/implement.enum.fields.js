const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	console.log(Color.Red);
	Color.DarkRed = Color(3);
	Color.DarkGreen = Color(4);
	Color.DarkBlue = Color(5);
	console.log(Color.DarkGreen);
	return {
		Color
	};
};