const {Operator} = require("@kaoscript/runtime");
module.exports = function() {
	const heroes = ["leto", "duncan", "goku"];
	for(let index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
		hero = heroes[index];
		if(!(Operator.lte(hero.length, 4))) {
			break;
		}
		console.log("The hero at index %d is %s", index, hero);
	}
};