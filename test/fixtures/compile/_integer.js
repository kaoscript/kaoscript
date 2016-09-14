module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let Integer = {
		parse(value = null, radix = null) {
			return parseInt(value, radix);
		}
	};
	return {
		Integer: Integer
	};
}