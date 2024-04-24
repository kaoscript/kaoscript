const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const value = "spice";
	let likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(const value in likes) {
		console.log(value);
	}
};