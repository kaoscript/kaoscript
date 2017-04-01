var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_foo_0(...args) {
			console.log(args);
		}
		foo() {
			return Greetings.prototype.__ks_func_foo_0.apply(this, arguments);
		}
		__ks_func_bar_0() {
		}
		__ks_func_bar_1(name, ...messages) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			console.log(name, messages);
		}
		bar() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_bar_0.apply(this);
			}
			else {
				return Greetings.prototype.__ks_func_bar_1.apply(this, arguments);
			}
		}
		__ks_func_baz_0() {
		}
		__ks_func_baz_1() {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let foo = arguments[++__ks_i];
			if(foo === void 0 || foo === null) {
				throw new TypeError("'foo' is not nullable");
			}
			let __ks__;
			let bar = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "bar";
			let qux = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "qux";
			console.log(foo, bar, qux);
		}
		baz() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_baz_0.apply(this);
			}
			else if(arguments.length >= 1 && arguments.length <= 3) {
				return Greetings.prototype.__ks_func_baz_1.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_qux_0() {
		}
		__ks_func_qux_1(name, priority, ...messages) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			if(priority === void 0 || priority === null) {
				priority = 1;
			}
			console.log(name, priority, messages);
		}
		qux() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_qux_0.apply(this);
			}
			else {
				return Greetings.prototype.__ks_func_qux_1.apply(this, arguments);
			}
		}
		__ks_func_corge_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			console.log(name);
		}
		__ks_func_corge_1() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let name = arguments[++__ks_i];
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			let message = arguments[++__ks_i];
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			let __ks__;
			let priority = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 1;
			console.log(name, priority, message);
		}
		corge() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_corge_0.apply(this, arguments);
			}
			else if(arguments.length === 2 || arguments.length === 3) {
				return Greetings.prototype.__ks_func_corge_1.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_grault_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			console.log(name);
		}
		__ks_func_grault_1() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let name = arguments[++__ks_i];
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			let __ks__;
			let priority = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 1;
			let message = arguments[++__ks_i];
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			console.log(name, priority, message);
		}
		grault() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_grault_0.apply(this, arguments);
			}
			else if(arguments.length === 2 || arguments.length === 3) {
				return Greetings.prototype.__ks_func_grault_1.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_garply_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			console.log(name);
		}
		__ks_func_garply_1() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let name = arguments[++__ks_i];
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			let message = arguments[++__ks_i];
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			let priority;
			if(arguments.length > 2 && (priority = arguments[++__ks_i]) !== void 0 && priority !== null) {
				if(!Type.isNumber(priority)) {
					throw new TypeError("'priority' is not of type 'Number'");
				}
			}
			else {
				priority = 1;
			}
			console.log(name, priority, message);
		}
		__ks_func_garply_2() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let name = arguments[++__ks_i];
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			let priority;
			if(arguments.length > 2 && (priority = arguments[++__ks_i]) !== void 0 && priority !== null) {
				if(!Type.isNumber(priority)) {
					throw new TypeError("'priority' is not of type 'Number'");
				}
			}
			else {
				priority = 1;
			}
			let messages = arguments[++__ks_i];
			if(messages === void 0 || messages === null) {
				throw new TypeError("'messages' is not nullable");
			}
			else if(!Type.isArray(messages)) {
				throw new TypeError("'messages' is not of type 'Array'");
			}
			console.log(name, priority, messages);
		}
		garply() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_garply_0.apply(this, arguments);
			}
			else if(arguments.length === 2 || arguments.length === 3) {
				if(Type.isString(arguments[1])) {
					return Greetings.prototype.__ks_func_garply_1.apply(this, arguments);
				}
				else {
					return Greetings.prototype.__ks_func_garply_2.apply(this, arguments);
				}
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_waldo_0() {
		}
		__ks_func_waldo_1(name, ...messages) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			let priority = 1;
			console.log(name, priority, messages);
		}
		waldo() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_waldo_0.apply(this);
			}
			else {
				return Greetings.prototype.__ks_func_waldo_1.apply(this, arguments);
			}
		}
	}
}