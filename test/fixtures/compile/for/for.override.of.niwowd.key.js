const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let value = (() => {
		const d = new OBJ();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(const __ks_value_1 in value) {
		console.log(__ks_value_1);
	}
};