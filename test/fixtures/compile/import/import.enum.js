require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Color = require("../export/.export.enum.color.ks.j5k8r9.ksb")().Color;
	let color = Color.Red;
	console.log(color);
	Helper.implEnum(Color, "DarkRed", 3, "DarkGreen", 4, "DarkBlue", 5);
	color = Color.DarkGreen;
	console.log(color);
	return {
		Colour: Color
	};
};