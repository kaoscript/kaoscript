module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foo.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
	}
	Foo.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 0,
				max: 0,
				parameters: []
			}
		],
		instanceVariables: {
			_bar: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
}