var {Helper, Type} = require("@kaoscript/runtime");
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
	}
	class Bar extends Foo {
		__ks_init() {
			Foo.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foo.prototype.__ks_cons.call(this, args);
		}
	}
	function bar() {
		if(arguments.length === 1 && Type.isClassInstance(arguments[0], Bar)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isClassInstance(x, Bar)) {
				throw new TypeError("'x' is not of type 'Bar'");
			}
			return 42;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isClassInstance(x, Foo)) {
				throw new TypeError("'x' is not of type 'Foo'");
			}
			return "";
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	let x = new Foo();
	console.log(bar(x));
	let y = new Bar();
	console.log(Helper.toString(bar(y)));
	let z = new Bar();
	console.log(Helper.toString(bar(z)));
};