const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let value = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(let __ks_0 in value) {
		const __ks_value_1 = value[__ks_0];
		console.log(__ks_value_1);
	}
};