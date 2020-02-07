var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper;
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
		console.log(Helper.concatString(key, " likes ", value));
	}
};