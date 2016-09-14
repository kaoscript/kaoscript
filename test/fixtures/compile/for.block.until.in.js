module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let heroes = ["leto", "duncan", "goku"];
	let index;
	for(let index = 0, __ks_0 = heroes.length, hero; !(index = 1) && index < __ks_0; ++index) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
}