const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	function spicyHeroes() {
		return spicyHeroes.__ks_rt(this, arguments);
	};
	spicyHeroes.__ks_0 = function() {
		return Helper.mapObject(likes, function(hero, like) {
			return hero;
		}, function(hero, like) {
			return like === "spice";
		});
	};
	spicyHeroes.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return spicyHeroes.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};