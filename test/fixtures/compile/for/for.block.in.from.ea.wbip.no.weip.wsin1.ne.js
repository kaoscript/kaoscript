module.exports = function() {
	const heroes = ["leto", "duncan", "goku", "batman", "asterix", "naruto", "totoro"];
	for(let index = Math.min(heroes.length - 1, 5), hero; index >= 2; --index) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
};