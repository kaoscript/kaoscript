const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(const key in likes) {
		const value = likes[key];
		console.log("%s likes %s", key, value);
	}
};