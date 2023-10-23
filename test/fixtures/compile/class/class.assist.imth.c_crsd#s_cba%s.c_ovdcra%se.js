const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Person {
		static __ks_new_0() {
			const o = Object.create(Person.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this.name = "";
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	class Student extends Person {
		static __ks_new_0() {
			const o = Object.create(Student.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this.class = "";
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class Greetings {
		static __ks_new_0() {
			const o = Object.create(Greetings.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		greet() {
			return this.__ks_func_greet_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_0(person, message) {
			if(message === void 0 || message === null) {
				message = "Bye!";
			}
			return "Hello " + person.name + "! " + message;
		}
		__ks_func_greet_1(person, message) {
			if(message === void 0) {
				message = "Bye!";
			}
			return Helper.concatString("Hello ", person.name, " of the class ", person.class, "! ", message);
		}
		__ks_func_greet_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Student);
			const t1 = value => Type.isClassInstance(value, Person);
			const t2 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_1.call(that, args[0], void 0);
				}
				if(t1(args[0])) {
					return proto.__ks_func_greet_0.call(that, args[0], void 0);
				}
				if(t2(args[0])) {
					return proto.__ks_func_greet_1.call(that, void 0, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0])) {
					if(t2(args[1])) {
						return proto.__ks_func_greet_1.call(that, args[0], args[1]);
					}
				}
				if(t1(args[0]) && t2(args[1])) {
					return proto.__ks_func_greet_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class MyGreetings extends Greetings {
		static __ks_new_0() {
			const o = Object.create(MyGreetings.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_greet_0(person, message) {
			if(message === void 0 || message === null) {
				message = "Bye!";
			}
			return "Hello " + person.name + "! " + message;
		}
	}
};