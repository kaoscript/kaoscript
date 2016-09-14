module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {Number, __ks_Number} = require("./_number.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	function hex(n) {
		if(n === undefined || n === null) {
			throw new Error("Missing parameter 'n'");
		}
		if(!(Type.isString(n) || Type.isNumber(n))) {
			throw new Error("Invalid type for parameter 'n'");
		}
		return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 255));
	}
	console.log(hex(128));
}