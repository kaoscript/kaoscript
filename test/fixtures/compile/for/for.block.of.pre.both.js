var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	let key, value;
	for(key in likes) {
		value = likes[key];
	}
	console.log("" + key + " likes " + value);
};