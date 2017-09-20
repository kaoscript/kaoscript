module.exports = function() {
	const value = "spice";
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(let value in likes) {
		console.log(value);
	}
};