var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_bar_0() {
			return this._bar;
		}
		__ks_func_bar_1(bar) {
			if(bar === undefined || bar === null) {
				throw new Error("Missing parameter 'bar'");
			}
			else if(!Type.is(bar, Bar)) {
				throw new Error("Invalid type for parameter 'bar'");
			}
			this._bar = bar;
			return this;
		}
		bar() {
			if(arguments.length === 0) {
				return Foo.prototype.__ks_func_bar_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Foo.prototype.__ks_func_bar_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Foo.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {
			_bar: {
				access: 1,
				type: "#Bar"
			}
		},
		classVariables: {},
		instanceMethods: {
			bar: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				},
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: "#Bar",
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {}
	};
	class Bar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_foo_0() {
			return this._foo;
		}
		__ks_func_foo_1(foo) {
			if(foo === undefined || foo === null) {
				throw new Error("Missing parameter 'foo'");
			}
			else if(!Type.is(foo, Foo)) {
				throw new Error("Invalid type for parameter 'foo'");
			}
			this._foo = foo;
			return this;
		}
		foo() {
			if(arguments.length === 0) {
				return Bar.prototype.__ks_func_foo_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Bar.prototype.__ks_func_foo_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Bar.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {
			_foo: {
				access: 1,
				type: Foo
			}
		},
		classVariables: {},
		instanceMethods: {
			foo: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				},
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: Foo,
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {}
	};
	Foo.__ks_reflect.instanceVariables._bar.type = Bar;
	Foo.__ks_reflect.instanceMethods.bar[1].parameters[0].type = Bar;
}