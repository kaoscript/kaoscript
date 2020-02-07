var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	let key = null, value = null;
	for(key in likes) {
		value = likes[key];
	}
	console.log(Helper.concatString(key, " likes ", value));
};