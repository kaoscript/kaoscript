module.exports = function() {
	let heroes = ["leto", "duncan", "goku"];
	let hero = null, index = null;
	index = 0;
	for(let __ks_0 = heroes.length; index < __ks_0; ++index) {
		hero = heroes[index];
	}
	console.log(hero, index);
};