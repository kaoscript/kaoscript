module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {Number, __ks_Number} = require("./_number.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	function foo() {
		return 0.32;
	}
	let l1 = foo() + 0.05;
	let l2 = foo() + 0.05;
	let ratio = l1 / l2;
	console.log(__ks_Number._im_round(ratio, 2));
}