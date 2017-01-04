var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let heroes = ["leto", "duncan", "goku"];
	let evenHeroes = Helper.mapArray(heroes, function(hero, index) {
		return hero;
	}, function(hero, index) {
		return (index % 2) === 0;
	});
}