var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	let spicyHeroes = Helper.mapObject(likes, (hero, like) => {
		return hero;
	}, (hero, like) => {
		return like === "spice";
	});
}