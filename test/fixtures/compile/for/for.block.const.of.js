module.exports = function() {
	let key = "you";
	let value = 42;
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(const key in likes) {
		const value = likes[key];
		console.log(key + " likes " + value);
	}
};