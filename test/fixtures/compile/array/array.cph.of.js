const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	const spicyHeroes = Helper.mapObject(likes, function(hero, like) {
		return hero;
	}, function(hero, like) {
		return like === "spice";
	});
};