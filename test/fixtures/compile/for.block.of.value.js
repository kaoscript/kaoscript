module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(let __ks_0 in likes) {
		let value = likes[__ks_0];
		console.log(value);
	}
}