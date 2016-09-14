module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = {
		message: "hello"
	};
	let message;
	if((message = foo.message).length > 0) {
		console.log(message);
	}
}