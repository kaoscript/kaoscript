var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function likes() {
		return (function() {
			var d = new Dictionary();
			d.leto = "spice";
			d.paul = "chani";
			d.duncan = "murbella";
			return d;
		})();
	}
	var __ks_0 = likes();
	for(var key in __ks_0) {
		var value = __ks_0[key];
		console.log(key + " likes " + value);
	}
};