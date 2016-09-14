module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let log = __ks_Function._cm_vcurry(console.log, console, "hello: ");
	log("foo");
}