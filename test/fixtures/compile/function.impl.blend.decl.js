module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function blend(x, y, percentage) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(!Type.isNumber(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		if(y === undefined || y === null) {
			throw new Error("Missing parameter 'y'");
		}
		if(!Type.isNumber(y)) {
			throw new Error("Invalid type for parameter 'y'");
		}
		if(percentage === undefined || percentage === null) {
			throw new Error("Missing parameter 'percentage'");
		}
		if(!Type.isNumber(percentage)) {
			throw new Error("Invalid type for parameter 'percentage'");
		}
		return ((1 - percentage) * x) + (percentage * y);
	}
}