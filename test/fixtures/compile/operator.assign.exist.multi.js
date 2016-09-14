module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = function() {
		return "otto";
	};
	let qux = function() {
		return "itti";
	};
	let x, __ks_0;
	if(Type.isValue(__ks_0 = foo()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
	else if(Type.isValue(__ks_0 = qux()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
}