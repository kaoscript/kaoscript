const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	const flag = false;
	const spicyHeroes = flag ? (() => {
		const a = [];
		for(const hero in likes) {
			const like = likes[hero];
			if(like === "spice") {
				a.push(hero);
			}
		}
		return a;
	})() : [];
	return {
		spicyHeroes
	};
};