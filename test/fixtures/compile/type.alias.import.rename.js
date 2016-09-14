module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {Number, __ks_Number} = require("./_number.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	var {String, __ks_String} = require("./_string.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	let x = 0;
	console.log(Type.isNumber(x) ? __ks_Number._im_toInt(x) : __ks_String._im_toInt(x));
}