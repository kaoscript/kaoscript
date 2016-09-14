module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = function() {
		return "otto";
	};
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo()) ? bar = __ks_0 : undefined;
	console.log(foo, bar);
}