module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function ratio(min, max) {
		if(min === undefined || min === null) {
			throw new Error("Missing parameter 'min'");
		}
		if(max === undefined || max === null) {
			throw new Error("Missing parameter 'max'");
		}
		return ((min + max) / 2).round(2);
	}
}