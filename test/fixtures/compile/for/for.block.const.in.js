module.exports = function() {
	let hero = "you";
	let index = 42;
	const heroes = ["leto", "duncan", "goku"];
	for(let index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
};