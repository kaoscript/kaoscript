const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let value = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let __ks_value_1 in value) {
		console.log(__ks_value_1);
	}
};