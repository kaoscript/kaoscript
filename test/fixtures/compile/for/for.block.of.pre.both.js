const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	let key, value;
	for(key in likes) {
		value = likes[key];
	}
	console.log(Helper.concatString(key, " likes ", value));
};