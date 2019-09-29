require("kaoscript/register");
module.exports = function() {
	var Color = require("../export/export.enum.color.ks")().Color;
	let color = Color.Red;
	console.log(color);
	Color.DarkRed = Color(3);
	Color.DarkGreen = Color(4);
	Color.DarkBlue = Color(5);
	color = Color.DarkGreen;
	console.log(color);
	return {
		Colour: Color
	};
};