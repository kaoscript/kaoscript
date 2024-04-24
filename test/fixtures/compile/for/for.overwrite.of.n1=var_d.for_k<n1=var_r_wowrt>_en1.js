const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let value = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(const __ks_value_1 in value) {
		console.log(__ks_value_1);
	}
};