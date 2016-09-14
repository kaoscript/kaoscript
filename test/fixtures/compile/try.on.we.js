module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	try {
		console.log("foobar");
	}
	catch(__ks_0) {
		if(Type.is(__ks_0, RangeError) {
			let error = __ks_0;
			console.log("RangeError", error);
		}
		else {
			let error = __ks_0;
			console.log("Error", error);
		}
	}
}