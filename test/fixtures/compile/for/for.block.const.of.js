const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let key = "you";
	let value = 42;
	let likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(const key in likes) {
		const value = likes[key];
		console.log(Helper.concatString(key, " likes ", value));
	}
};