module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let key = "qux";
	var {[key]: foo} = {
		qux: "bar"
	};
	console.log(foo);
}