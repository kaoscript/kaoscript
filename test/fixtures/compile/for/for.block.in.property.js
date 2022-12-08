const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let characters = (() => {
		const d = new OBJ();
		d.heroes = ["leto", "duncan", "goku"];
		return d;
	})();
	for(let __ks_0 = 0, __ks_1 = characters.heroes.length, hero; __ks_0 < __ks_1; ++__ks_0) {
		hero = characters.heroes[__ks_0];
		console.log(hero);
	}
};