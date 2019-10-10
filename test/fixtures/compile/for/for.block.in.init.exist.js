module.exports = function() {
	function print(heroes) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(heroes === void 0 || heroes === null) {
			throw new TypeError("'heroes' is not nullable");
		}
		let hero;
		for(let __ks_0 = 0, __ks_1 = heroes.length; __ks_0 < __ks_1; ++__ks_0) {
			hero = heroes[__ks_0];
			console.log(hero.name);
		}
	}
};