const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	let key = null;
	for(key in likes) {
	}
	console.log(key);
};