module.exports = function() {
	let characters = {
		heroes: ["leto", "duncan", "goku"]
	};
	for(let __ks_0 = 0, __ks_1 = characters.heroes.length, hero; __ks_0 < __ks_1; ++__ks_0) {
		hero = characters.heroes[__ks_0];
		console.log(hero);
	}
};