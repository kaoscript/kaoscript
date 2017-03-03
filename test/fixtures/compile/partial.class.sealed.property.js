var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Array = {};
	Helper.newInstanceMethod({
		class: Array,
		name: "pushUniq",
		sealed: __ks_Array,
		function: function(...args) {
			return this;
		},
		signature: {
			access: 3,
			min: 0,
			max: Infinity,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: Infinity
				}
			]
		}
	});
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this.values = [];
		}
		__ks_init() {
			Foobar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	Foobar.__ks_reflect = {
		inits: 1,
		constructors: [],
		destructors: 0,
		instanceVariables: {
			values: {
				access: 3,
				type: "Array"
			}
		},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	const foobar = new Foobar();
	__ks_Array._im_pushUniq(foobar.values, 42);
}