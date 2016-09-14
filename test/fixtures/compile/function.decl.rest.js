module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function foo(bar, ...qux) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
	}
}