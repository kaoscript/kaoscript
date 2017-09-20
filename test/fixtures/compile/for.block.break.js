module.exports = function() {
	for(let x = 0; x <= 10; x += 2) {
		if(x > 5) {
			break;
		}
		console.log(x);
	}
};