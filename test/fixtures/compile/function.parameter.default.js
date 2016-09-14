module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function foo(item) {
		if(item === undefined || item === null) {
			item = 1;
		}
		console.log(item);
	}
	function bar(item) {
		if(item === undefined || item === null) {
			item = 1;
		}
		console.log(item);
	}
	function baz(item) {
		if(item === undefined) {
			item = 1;
		}
		console.log(item);
	}
	function qux(item) {
		if(item === undefined || item === null) {
			item = 1;
		}
		if(!Type.isNumber(item)) {
			throw new Error("Invalid type for parameter 'item'");
		}
		console.log(item);
	}
	function quux(item) {
		if(item === undefined) {
			item = 1;
		}
		if(item !== null && !Type.isNumber(item)) {
			throw new Error("Invalid type for parameter 'item'");
		}
		console.log(item);
	}
}