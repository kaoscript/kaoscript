module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let heroes = ["leto", "duncan", "goku"];
	let evenHeroes = __ks_Array._cm_map(heroes, (hero, index) => {
		return hero;
	}, (hero, index) => {
		return (index % 2) === 0;
	});
}