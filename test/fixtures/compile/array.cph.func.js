var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	function spicyHeroes() {
		return spicyHeroes = Helper.mapObject(likes, (hero, like) => {
			return hero;
		}, (hero, like) => {
			return like === "spice";
		});
	}
}