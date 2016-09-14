module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let left = 10;
	let right = 20;
	if(right > left) {
		[left, right] = [right, left];
	}
	console.log(left, right);
}