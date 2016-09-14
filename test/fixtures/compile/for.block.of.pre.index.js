module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	let key;
	let value;
	for(key in likes) {
		value = likes[key];
	}
	console.log(key + " likes " + value);
}