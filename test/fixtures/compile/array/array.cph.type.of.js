var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	const flag = false;
	const spicyHeroes = flag ? Helper.mapDictionary(likes, function(hero, like) {
		return hero;
	}, function(hero, like) {
		return like === "spice";
	}) : [];
	return {
		spicyHeroes: spicyHeroes
	};
};