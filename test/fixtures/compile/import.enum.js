module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var Color = require("./export.enum.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type).Color;
	let color = Color.Red;
	console.log(color);
	Color.DarkRed = 3;
	Color.DarkGreen = 4;
	Color.DarkBlue = 5;
	let color = Color.DarkGreen;
	console.log(color);
	return {
		Colour: Color
	};
}