module.exports = function() {
	var {Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type} = require("./polyfill.ks")();
	Class.newClassMethod({
		class: Object,
		name: "clone",
		final: __ks_Object,
		function: function(object) {
			if(object === undefined || object === null) {
				throw new Error("Missing parameter 'object'");
			}
			if((Type.isFunction(object.constructor.clone)) && (object.constructor.clone !== this)) {
				return object.constructor.clone(object);
			}
			if(Type.isFunction(object.constructor.prototype.clone)) {
				return object.clone();
			}
			let clone = {};
			for(let key in object) {
				let value = object[key];
				if(Type.isArray(value)) {
					clone[key] = value.clone();
				}
				else if(Type.isObject(value)) {
					clone[key] = __ks_Object._cm_clone(value);
				}
				else {
					clone[key] = value;
				}
			}
			return clone;
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 1
				}
			]
		}
	});
}