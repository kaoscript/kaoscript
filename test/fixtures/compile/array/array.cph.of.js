const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	const spicyHeroes = (() => {
		const a = [];
		for(const hero in likes) {
			const like = likes[hero];
			if(like === "spice") {
				a.push(hero);
			}
		}
		return a;
	})();
};