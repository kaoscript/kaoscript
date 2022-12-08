const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let key = "you";
	let value = 42;
	let likes = (() => {
		const d = new OBJ();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(const key in likes) {
		const value = likes[key];
		console.log(Helper.concatString(key, " likes ", value));
	}
};