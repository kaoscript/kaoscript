module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = {
		bar: "hello",
		baz: 3
	};
	var {bar: a, baz: b} = foo;
	console.log(a);
	console.log(b);
}