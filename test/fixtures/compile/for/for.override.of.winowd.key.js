const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	const value = "spice";
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(const value in likes) {
		console.log(value);
	}
};