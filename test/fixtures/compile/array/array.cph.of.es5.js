var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	let spicyHeroes = Helper.mapObject(likes, function(hero, like) {
		return hero;
	}, function(hero, like) {
		return like === "spice";
	});
};