const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const heroes = ["leto", "duncan", "goku"];
	const flag = false;
	const evenHeroes = flag ? Helper.mapArray(heroes, function(hero, index) {
		return hero;
	}, function(hero, index) {
		return (index % 2) === 0;
	}) : [];
	return {
		evenHeroes
	};
};