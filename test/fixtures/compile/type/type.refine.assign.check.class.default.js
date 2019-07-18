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
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foo_0() {
			return "";
		}
		foo() {
			if(arguments.length === 0) {
				return Foo.prototype.__ks_func_foo_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Bar extends Foo {
		__ks_init() {
			Foo.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foo.prototype.__ks_cons.call(this, args);
		}
		__ks_func_bar_0() {
			return "";
		}
		bar() {
			if(arguments.length === 0) {
				return Bar.prototype.__ks_func_bar_0.apply(this);
			}
			else if(Foo.prototype.bar) {
				return Foo.prototype.bar.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	function bar() {
		return new Bar();
	}
	let x = new Foo();
	console.log(x.foo());
	console.log("" + x.bar());
	x = bar();
	console.log(x.foo());
	console.log(x.bar());
	let y = new Bar();
	console.log(y.foo());
	console.log(y.bar());
	let z = new Bar();
	console.log(z.foo());
	console.log(z.bar());
	return {
		Foo: Foo,
		Bar: Bar,
		x: x,
		y: y,
		z: z
	};
};