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
	class ClassB {
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
	function __ks_foobar_0(a, b) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(a === void 0) {
			a = null;
		}
		else if(a !== null && !Type.isClassInstance(a, ClassA)) {
			throw new TypeError("'a' is not of type 'ClassA?'");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		else if(!Type.isClassInstance(b, ClassB)) {
			throw new TypeError("'b' is not of type 'ClassB'");
		}
		let __ks_i = 1;
		let c;
		if(arguments.length > ++__ks_i && (c = arguments[__ks_i]) !== void 0 && c !== null) {
			if(!Type.isNumber(c)) {
				if(arguments.length - __ks_i < 3) {
					c = 1;
					--__ks_i;
				}
				else {
					throw new TypeError("'c' is not of type 'Number'");
				}
			}
		}
		else {
			c = 1;
		}
		let d;
		if(arguments.length > ++__ks_i && (d = arguments[__ks_i]) !== void 0 && d !== null) {
			if(!Type.isNumber(d)) {
				if(arguments.length - __ks_i < 2) {
					d = 1;
					--__ks_i;
				}
				else {
					throw new TypeError("'d' is not of type 'Number'");
				}
			}
		}
		else {
			d = 1;
		}
		let e;
		if(arguments.length > ++__ks_i && (e = arguments[__ks_i]) !== void 0 && e !== null) {
			if(!Type.isBoolean(e)) {
				throw new TypeError("'e' is not of type 'Boolean'");
			}
		}
		else {
			e = false;
		}
		return 0;
	}
	function __ks_foobar_1(a, n, b) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(a === void 0) {
			a = null;
		}
		else if(a !== null && !Type.isClassInstance(a, ClassA)) {
			throw new TypeError("'a' is not of type 'ClassA?'");
		}
		if(n === void 0) {
			n = null;
		}
		else if(n !== null && !Type.isString(n)) {
			throw new TypeError("'n' is not of type 'String?'");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		else if(!Type.isClassInstance(b, ClassB)) {
			throw new TypeError("'b' is not of type 'ClassB'");
		}
		let __ks_i = 2;
		let c;
		if(arguments.length > ++__ks_i && (c = arguments[__ks_i]) !== void 0 && c !== null) {
			if(!Type.isNumber(c)) {
				if(arguments.length - __ks_i < 3) {
					c = 1;
					--__ks_i;
				}
				else {
					throw new TypeError("'c' is not of type 'Number'");
				}
			}
		}
		else {
			c = 1;
		}
		let d;
		if(arguments.length > ++__ks_i && (d = arguments[__ks_i]) !== void 0 && d !== null) {
			if(!Type.isNumber(d)) {
				if(arguments.length - __ks_i < 2) {
					d = 1;
					--__ks_i;
				}
				else {
					throw new TypeError("'d' is not of type 'Number'");
				}
			}
		}
		else {
			d = 1;
		}
		let e;
		if(arguments.length > ++__ks_i && (e = arguments[__ks_i]) !== void 0 && e !== null) {
			if(!Type.isBoolean(e)) {
				throw new TypeError("'e' is not of type 'Boolean'");
			}
		}
		else {
			e = false;
		}
		return 1;
	}
	function foobar() {
		if(arguments.length === 2) {
			return __ks_foobar_0(...arguments);
		}
		else if(arguments.length === 3) {
			if(Type.isString(arguments[1])) {
				return __ks_foobar_1(...arguments);
			}
			else {
				return __ks_foobar_0(...arguments);
			}
		}
		else if(arguments.length === 4 || arguments.length === 5) {
			if(Type.isNumber(arguments[2])) {
				return __ks_foobar_0(...arguments);
			}
			else {
				return __ks_foobar_1(...arguments);
			}
		}
		else if(arguments.length === 6) {
			return __ks_foobar_1(...arguments);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};