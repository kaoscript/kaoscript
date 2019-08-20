module.exports = function() {
	let heroes = ["leto", "duncan", "goku", "batman", "asterix", "naruto", "totoro"];
	for(let index = Math.min(heroes.length - 1, 5), __ks_0 = 2, hero; index >= __ks_0; index -= 2) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
};