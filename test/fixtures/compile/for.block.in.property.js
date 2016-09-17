module.exports = function() {
	let characters = {
		heroes: ["leto", "duncan", "goku"]
	};
	let __ks_0 = characters.heroes;
	for(let __ks_1 = 0, __ks_2 = __ks_0.length, hero; __ks_1 < __ks_2; ++__ks_1) {
		hero = __ks_0[__ks_1];
		console.log(hero);
	}
}