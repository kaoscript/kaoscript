var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			if(arguments.length > 1) {
				var foo = arguments[++__ks_i];
			}
			else {
				var foo = "hello";
			}
			if(Type.isString(arguments[++__ks_i])) {
				var bar = arguments[__ks_i];
			}
			else throw new Error("Invalid type for parameter 'bar'")
		}
		__ks_cons_1() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			if(arguments.length > 2) {
				var foo = arguments[++__ks_i];
			}
			else {
				var foo = "hello";
			}
			if(Type.isString(arguments[++__ks_i])) {
				var bar = arguments[__ks_i];
			}
			else throw new Error("Invalid type for parameter 'bar'")
			var qux = arguments[++__ks_i];
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Foo.prototype.__ks_cons_0.apply(this, args);
			}
			else if(args.length === 2) {
				if(Type.isString(args[0])) {
					Foo.prototype.__ks_cons_1.apply(this, args);
				}
				else {
					Foo.prototype.__ks_cons_0.apply(this, args);
				}
			}
			else if(args.length === 3) {
				Foo.prototype.__ks_cons_1.apply(this, args);
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
				min: 1,
				max: 2,
				parameters: [
					{
						type: "Any",
						min: 0,
						max: 1
					},
					{
						type: "String",
						min: 1,
						max: 1
					}
				]
			},
			{
				access: 3,
				min: 2,
				max: 3,
				parameters: [
					{
						type: "Any",
						min: 0,
						max: 1
					},
					{
						type: "String",
						min: 1,
						max: 1
					},
					{
						type: "Any",
						min: 1,
						max: 1
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
}