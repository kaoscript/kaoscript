const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const heroes = ["leto", "duncan", "goku"];
	const inverted = (() => {
		const o = new OBJ();
		for(let index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
			hero = heroes[index];
			o[hero] = index;
		}
		return o;
	})();
};