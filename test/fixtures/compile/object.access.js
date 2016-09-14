module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function dot(foo) {
		if(foo === undefined || foo === null) {
			throw new Error("Missing parameter 'foo'");
		}
		return foo.bar;
	}
	function bracket(foo, bar) {
		if(foo === undefined || foo === null) {
			throw new Error("Missing parameter 'foo'");
		}
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
		return foo[bar];
	}
}