module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function foo(bar = null) {
		let qux;
		if(Type.isValue(bar) ? (qux = bar, true) : false) {
			console.log(qux);
		}
	}
}