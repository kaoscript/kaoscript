module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {Color, Space} = require("./_color.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	var {Color, Space} = require("./_color.cie.ks")(Color, Space, Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	console.log(Color, Space);
}