var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (function() {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	let spicyHeroes = Helper.mapDictionary(likes, function(hero, like) {
		return hero;
	}, function(hero, like) {
		return like === "spice";
	});
};