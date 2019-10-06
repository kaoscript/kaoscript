var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function likes() {
		return (() => {
			const d = new Dictionary();
			d.leto = "spice";
			d.paul = "chani";
			d.duncan = "murbella";
			return d;
		})();
	}
	{
		let __ks_0 = likes();
		for(let key in __ks_0) {
			let value = __ks_0[key];
			console.log(key + " likes " + value);
		}
	}
};