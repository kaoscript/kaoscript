module.exports = function() {
	let heroes = ["leto", "duncan", "goku"];
	for(let index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
		hero = heroes[index];
		if((index % 2) === 0) {
			console.log(hero);
		}
	}
}