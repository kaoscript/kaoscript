module.exports = function() {
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