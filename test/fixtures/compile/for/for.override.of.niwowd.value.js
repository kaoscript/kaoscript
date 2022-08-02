const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let value = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let __ks_0 in value) {
		const __ks_value_1 = value[__ks_0];
		console.log(__ks_value_1);
	}
};