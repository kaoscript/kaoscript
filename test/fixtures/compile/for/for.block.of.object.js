const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(let key in likes) {
		let value = likes[key];
		console.log(Helper.concatString(key, " likes ", value));
	}
};