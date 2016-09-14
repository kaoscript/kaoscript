module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = {
		bar: {
			n1: "hello",
			n2: "world"
		}
	};
	var {bar: {n1, n2: qux}} = foo;
	console.log(n1, qux);
}