var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let key in likes) {
		let value = likes[key];
		if(value === "chani") {
			break;
		}
		console.log(key + " likes " + value);
	}
};