const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class AbstractGreetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._message = "";
		}
		__ks_cons_0() {
			AbstractGreetings.prototype.__ks_cons_1.call(this, "Hello!");
		}
		__ks_cons_1(message) {
			this._message = message;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return AbstractGreetings.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return AbstractGreetings.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Greetings extends AbstractGreetings {
		static __ks_new_0(...args) {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(name) {
			AbstractGreetings.prototype.__ks_cons_0.call(this);
			this._name = name;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Greetings.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		greet() {
			return this.__ks_func_greet_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_1(name) {
			if(name === void 0 || name === null) {
				name = this._name;
			}
			return Helper.concatString(this._message, " My name is ", name, ".");
		}
		__ks_func_greet_0(name) {
			return this.__ks_func_greet_1(name);
		}
		__ks_func_greet_rt(that, proto, args) {
			if(args.length <= 1) {
				return proto.__ks_func_greet_1.call(that, args[0]);
			}
			if(super.__ks_func_greet_rt) {
				return super.__ks_func_greet_rt.call(null, that, AbstractGreetings.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	const greetings = Greetings.__ks_new_0("John");
	console.log(greetings.__ks_func_greet_1());
	console.log(greetings.__ks_func_greet_1("John"));
};