module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	let spicyHeroes = __ks_Object._cm_map(likes, (hero, like) => {
		return hero;
	}, (hero, like) => {
		return like === "spice";
	});
}