module.exports = function() {
	const heroes = ["leto", "duncan", "goku"];
	const flag = false;
	const evenHeroes = flag ? (() => {
		const a = [];
		for(let index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
			hero = heroes[index];
			if((index % 2) === 0) {
				a.push(hero);
			}
		}
		return a;
	})() : [];
	return {
		evenHeroes
	};
};