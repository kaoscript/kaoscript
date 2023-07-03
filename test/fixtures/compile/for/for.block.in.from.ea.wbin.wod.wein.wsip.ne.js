module.exports = function() {
	const heroes = ["leto", "duncan", "goku", "batman", "asterix", "naruto", "totoro"];
	for(let index = Math.max(0, heroes.length - 2), __ks_0 = heroes.length - 5, hero; index >= __ks_0; index += 2) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
};