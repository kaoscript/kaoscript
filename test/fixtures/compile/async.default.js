module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function foo(bar, qux, __ks_cb) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
		if(!Type.isString(bar)) {
			throw new Error("Invalid type for parameter 'bar'");
		}
		if(qux === undefined || qux === null) {
			throw new Error("Missing parameter 'qux'");
		}
		if(!Type.isNumber(qux)) {
			throw new Error("Invalid type for parameter 'qux'");
		}
		if(!Type.isFunction(__ks_cb)) {
			throw new Error("Invalid callback");
		}
	}
}