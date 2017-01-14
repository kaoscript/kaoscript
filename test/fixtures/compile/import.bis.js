require("kaoscript/register");
module.exports = function() {
	var Colour = require("./import.enum.ks")().Colour;
	console.log(Colour.Red);
	console.log(Colour.DarkGreen);
}