module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var {Array, __ks_Array} = require("./_array.ks")(Class, Type);
	function foo(...items) {
		console.log(__ks_Array._im_last(items));
	}
}