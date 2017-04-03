module.exports = function() {
	const likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(let key in likes) {
		let value = likes[key];
		console.log(key + " likes " + value);
	}
}