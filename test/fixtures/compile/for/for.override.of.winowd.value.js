const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const value = "spice";
	let likes = (() => {
		const d = new OBJ();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let __ks_0 in likes) {
		const value = likes[__ks_0];
		console.log(value);
	}
};