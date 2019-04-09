module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(let key in likes) {
		let value = likes[key];
		if(!(value.length <= 5)) {
			break;
		}
		console.log(key + " likes " + value);
	}
};