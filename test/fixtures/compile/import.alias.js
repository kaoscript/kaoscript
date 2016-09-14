module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var foo = require("./export.default.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type).name;
	console.log(foo);
}