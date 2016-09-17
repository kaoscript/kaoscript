module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(bar) {
			if(bar === undefined || bar === null) {
				throw new Error("Missing parameter 'bar'");
			}
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Foo.prototype.__ks_cons_0.apply(this, args);
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
				max: 1,
				parameters: [
					{
						type: "Any",
						min: 1,
						max: 1
					}
				]
			}
		],
		instanceVariables: {
		},
		classVariables: {
		},
		instanceMethods: {
		},
		classMethods: {
		}
	};
	class Bar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._foo = new Foo(this);
		}
		__ks_init() {
			Bar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new Error("Wrong number of arguments");
			}
		}
	}
	Bar.__ks_reflect = {
		inits: 1,
		constructors: [
		],
		instanceVariables: {
			_foo: {
				access: 1,
				type: Foo
			}
		},
		classVariables: {
		},
		instanceMethods: {
		},
		classMethods: {
		}
	};
}