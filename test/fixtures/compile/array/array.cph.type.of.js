var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	const likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	const flag = false;
	const spicyHeroes = flag ? Helper.mapObject(likes, function(hero, like) {
		return hero;
	}, function(hero, like) {
		return like === "spice";
	}) : [];
	return {
		spicyHeroes: spicyHeroes
	};
};