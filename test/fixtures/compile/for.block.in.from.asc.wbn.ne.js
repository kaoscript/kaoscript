module.exports = function() {
	let heroes = ["leto", "duncan", "goku", "batman", "asterix", "naruto", "totoro"];
	for(let index = Math.max(0, heroes.length - 2), __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
}