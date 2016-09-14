module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {console, Shape, __ks_Shape} = require("./export.final.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	let shape = new Shape("yellow");
	console.log(__ks_Shape._im_draw(shape, "rectangle"));
}