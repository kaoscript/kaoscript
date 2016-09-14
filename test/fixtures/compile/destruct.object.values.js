module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {foo = 3} = {
		foo: 2
	};
	console.log(foo);
	var {foo = 3} = {
		foo: null
	};
	console.log(foo);
	var {foo = 5} = {
		bar: 2
	};
	console.log(foo);
}