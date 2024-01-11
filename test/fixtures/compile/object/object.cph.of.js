const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	const inverted = (() => {
		const o = new OBJ();
		for(const hero in likes) {
			const like = likes[hero];
			o[like] = hero;
		}
		return o;
	})();
};