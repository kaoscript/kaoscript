module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {Number, __ks_Number} = require("./_number.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	var {String, __ks_String} = require("./_string.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	function degree(value) {
		if(value === undefined || value === null) {
			throw new Error("Missing parameter 'value'");
		}
		if(!(Type.isNumber(value) || Type.isString(value))) {
			throw new Error("Invalid type for parameter 'value'");
		}
		return __ks_Number._im_mod(Type.isNumber(value) ? __ks_Number._im_toInt(value) : __ks_String._im_toInt(value), 360);
	}
}