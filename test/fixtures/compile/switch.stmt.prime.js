module.exports = function() {
	let number = 13;
	if(number === 1) {
		console.log("One!");
	}
	else if(number === 2 || number === 3 || number === 5 || number === 7 || number === 11) {
		console.log("This is a prime");
	}
	else if(number >= 13 && number <= 19) {
		console.log("A teen");
	}
	else {
		console.log("Ain't special");
	}
}