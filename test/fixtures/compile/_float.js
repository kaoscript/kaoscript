module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let Float = {
		parse(value = null) {
			return parseFloat(value);
		}
	};
	return {
		Float: Float
	};
}