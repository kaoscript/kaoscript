const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let __ks_0 in likes) {
		let value = likes[__ks_0];
		console.log(value);
	}
};