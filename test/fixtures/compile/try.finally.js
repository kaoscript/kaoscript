module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let __ks_0 = () => {
		console.log("finally");
	};
	try {
		console.log("foobar");
		__ks_0();
	}
	catch(__ks_1) {
		__ks_0();
	}
}