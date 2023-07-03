const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(let __ks_0 in likes) {
		const value = likes[__ks_0];
		console.log(value);
	}
};