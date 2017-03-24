module.exports = function() {
	class name {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	name.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	function foo() {
		let name = "foobar";
	}
}