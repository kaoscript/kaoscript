module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let temperature = 83;
	if(temperature >= 0 && temperature <= 49) {
		console.log("Cold");
	}
	else if(temperature >= 50 && temperature <= 79) {
		console.log("Warm");
	}
	else if(temperature >= 80 && temperature <= 110) {
		console.log("Hot");
	}
	else {
		console.log("Temperature out of range");
	}
}