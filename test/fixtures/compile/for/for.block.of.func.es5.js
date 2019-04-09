module.exports = function() {
	function likes() {
		return {
			leto: "spice",
			paul: "chani",
			duncan: "murbella"
		};
	}
	var __ks_0 = likes();
	for(var key in __ks_0) {
		var value = __ks_0[key];
		console.log(key + " likes " + value);
	}
};