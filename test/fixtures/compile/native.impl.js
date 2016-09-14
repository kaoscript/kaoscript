module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var __ks_String = {};
	Class.newInstanceMethod({
		class: String,
		name: "lowerFirst",
		final: __ks_String,
		function: function() {
			return this.charAt(0).toLowerCase() + this.substring(1);
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: [
			]
		}
	});
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lowerFirst(foo));
}