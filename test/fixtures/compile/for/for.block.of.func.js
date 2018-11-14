module.exports = function() {
	function likes() {
		return {
			leto: "spice",
			paul: "chani",
			duncan: "murbella"
		};
	}
	let __ks_0 = likes();
	for(let key in __ks_0) {
		let value = __ks_0[key];
		console.log(key + " likes " + value);
	}
};