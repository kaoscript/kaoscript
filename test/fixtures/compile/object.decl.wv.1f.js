module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	let foo = {
		bar(name = null) {
			if(name !== null && !Type.isString(name)) {
				throw new Error("Invalid type for parameter 'name'");
			}
			let n = 0;
		}
	};
}