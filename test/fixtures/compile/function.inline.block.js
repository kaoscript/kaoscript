module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	const foo = function(a, b) {
		if(a === undefined || a === null) {
			throw new Error("Missing parameter 'a'");
		}
		if(!Type.isNumber(a)) {
			throw new Error("Invalid type for parameter 'a'");
		}
		if(b === undefined || b === null) {
			throw new Error("Missing parameter 'b'");
		}
		if(!Type.isNumber(b)) {
			throw new Error("Invalid type for parameter 'b'");
		}
		return a - b;
	};
}