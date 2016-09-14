module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let temperature = 54;
	if(temperature >= 0 && temperature <= 49 && (temperature % 2) === 0) {
		console.log("Cold and even");
	}
	else if(temperature >= 50 && temperature <= 79 && (temperature % 2) === 0) {
		console.log("Warm and even");
	}
	else if(temperature >= 80 && temperature <= 110 && (temperature % 2) === 0) {
		console.log("Hot and even");
	}
	else {
		console.log("Temperature out of range or odd");
	}
}