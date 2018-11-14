require("kaoscript/register");
module.exports = function() {
	var Color = require("../export/export.enum.ks")().Color;
	let color = Color.Red;
	console.log(color);
	Color.DarkRed = 3;
	Color.DarkGreen = 4;
	Color.DarkBlue = 5;
	color = Color.DarkGreen;
	console.log(color);
	return {
		Colour: Color
	};
};