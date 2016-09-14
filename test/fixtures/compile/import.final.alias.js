module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var T = require("./export.final.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	let shape = new T.Shape("yellow");
	T.console.log(T.__ks_Shape._im_draw(shape, "rectangle"));
}