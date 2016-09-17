module.exports = function() {
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