var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(foo, bar) {
			if(foo === undefined || foo === null) {
				throw new Error("Missing parameter 'foo'");
			}
			if(bar === undefined || bar === null) {
				throw new Error("Missing parameter 'bar'");
			}
			else if(!Type.isString(bar)) {
				throw new Error("Invalid type for parameter 'bar'");
			}
		}
		__ks_cons_1(foo, bar, qux) {
			if(foo === undefined || foo === null) {
				throw new Error("Missing parameter 'foo'");
			}
			if(bar === undefined || bar === null) {
				throw new Error("Missing parameter 'bar'");
			}
			else if(!Type.isString(bar)) {
				throw new Error("Invalid type for parameter 'bar'");
			}
			if(qux === undefined || qux === null) {
				throw new Error("Missing parameter 'qux'");
			}
		}
		__ks_cons_2(foo, bar, qux) {
			if(foo === undefined || foo === null) {
				throw new Error("Missing parameter 'foo'");
			}
			if(bar === undefined || bar === null) {
				throw new Error("Missing parameter 'bar'");
			}
			if(qux === undefined || qux === null) {
				throw new Error("Missing parameter 'qux'");
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Foo.prototype.__ks_cons_0.apply(this, args);
			}
			else if(args.length === 3) {
				if(Type.isString(args[1])) {
					Foo.prototype.__ks_cons_1.apply(this, args);
				}
				else {
					Foo.prototype.__ks_cons_2.apply(this, args);
				}
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
				min: 2,
				max: 2,
				parameters: [
					{
						type: "Any",
						min: 1,
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
				min: 3,
				max: 3,
				parameters: [
					{
						type: "Any",
						min: 1,
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
			},
			{
				access: 3,
				min: 3,
				max: 3,
				parameters: [
					{
						type: "Any",
						min: 3,
						max: 3
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