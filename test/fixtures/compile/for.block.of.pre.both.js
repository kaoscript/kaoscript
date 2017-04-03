module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	let key, value;
	for(key in likes) {
		value = likes[key];
	}
	console.log("" + key + " likes " + value);
}