const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const d = new OBJ();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let key in likes) {
		let value = likes[key];
		console.log("%s likes %s", key, value);
	}
};