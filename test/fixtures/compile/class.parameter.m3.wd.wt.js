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
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let __ks__;
			let foo = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
			let bar = arguments[++__ks_i];
			if(bar === void 0 || bar === null) {
				throw new TypeError("'bar' is not nullable");
			}
			else if(!Type.isString(bar)) {
				throw new TypeError("'bar' is not of type 'String'");
			}
		}
		__ks_cons_1() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let __ks__;
			let foo = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
			let bar = arguments[++__ks_i];
			if(bar === void 0 || bar === null) {
				throw new TypeError("'bar' is not nullable");
			}
			else if(!Type.isString(bar)) {
				throw new TypeError("'bar' is not of type 'String'");
			}
			let qux = arguments[++__ks_i];
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
		}
		__ks_cons_2() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let __ks__;
			let foo = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
			let bar = arguments[++__ks_i];
			if(bar === void 0 || bar === null) {
				throw new TypeError("'bar' is not nullable");
			}
			let qux = arguments[++__ks_i];
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
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
					if(Type.isString(args[1])) {
						Foo.prototype.__ks_cons_0.apply(this, args);
					}
					else {
						Foo.prototype.__ks_cons_2.apply(this, args);
					}
				}
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
				throw new SyntaxError("wrong number of arguments");
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
			},
			{
				access: 3,
				min: 2,
				max: 3,
				parameters: [
					{
						type: "Any",
						min: 2,
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