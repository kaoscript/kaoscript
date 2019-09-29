var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	console.log(Color.Red);
	Color.DarkRed = Color(3);
	Color.DarkGreen = Color(4);
	Color.DarkBlue = Color(5);
	console.log(Color.DarkGreen);
};