var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(!Type.isString(name)) {
				throw new Error("Invalid type for parameter 'name'");
			}
			this.name = name;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Foo.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_qux_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			this.bar = "Hello " + name;
		}
		qux() {
			if(arguments.length === 1) {
				return Foo.prototype.__ks_func_qux_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Foo.bar = "Hello world!";
	Foo.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 1,
				max: 1,
				parameters: [
					{
						type: "String",
						min: 1,
						max: 1
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {
			name: {
				access: 3,
				type: "String"
			}
		},
		classVariables: {
			bar: {
				access: 3,
				type: "String"
			}
		},
		instanceMethods: {
			qux: [
				{
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
			]
		},
		classMethods: {}
	};
	console.log(Foo.bar);
	let foo = new Foo("xyz");
	console.log(foo.name);
	return {
		Foo: Foo
	};
}