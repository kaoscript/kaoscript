var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	Helper.newClassMethod({
		class: Object,
		name: "clone",
		sealed: __ks_Object,
		function: function(object) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(object === void 0 || object === null) {
				throw new TypeError("'object' is not nullable");
			}
			if(Type.isFunction(object.constructor.clone) && (object.constructor.clone !== this)) {
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