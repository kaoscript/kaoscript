var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class ClassA {
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
	class ClassB extends ClassA {
		__ks_init_1() {
			this._x = 42;
		}
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
			ClassB.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			ClassA.prototype.__ks_cons.call(this, []);
		}
		__ks_cons_1(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			ClassB.prototype.__ks_cons.call(this, []);
			this._x = x;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				ClassB.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				ClassB.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class ClassC extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			ClassC.prototype.__ks_cons.call(this, [name, "home"]);
		}
		__ks_cons_1(name, domain) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			if(domain === void 0 || domain === null) {
				throw new TypeError("'domain' is not nullable");
			}
			else if(!Type.isString(domain)) {
				throw new TypeError("'domain' is not of type 'String'");
			}
			this._name = name;
			this._domain = domain;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				ClassC.prototype.__ks_cons_0.apply(this, args);
			}
			else if(args.length === 2) {
				ClassC.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};