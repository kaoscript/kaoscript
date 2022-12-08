const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const d = new OBJ();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	let key, value;
	for(key in likes) {
		value = likes[key];
	}
	console.log(Helper.concatString(key, " likes ", value));
};