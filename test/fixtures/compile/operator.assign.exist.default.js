module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = "otto";
	let bar;
	Type.isValue(foo) ? bar = foo : undefined;
	console.log(foo, bar);
}