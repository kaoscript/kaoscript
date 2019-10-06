var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let key = "you";
	let value = 42;
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(const key in likes) {
		const value = likes[key];
		console.log(key + " likes " + value);
	}
};