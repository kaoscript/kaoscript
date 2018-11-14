module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(let key in likes) {
		let value = likes[key];
		if(key.indexOf("a") !== 0) {
			console.log(key + " likes " + value);
		}
	}
};