module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {String, __ks_String} = require("./_string.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lower(foo));
}