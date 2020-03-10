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
	function foobar() {
		if(arguments.length === 2 || (arguments.length >= 3 && arguments.length <= 5 && Type.isNumber(arguments[2]))) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0) {
				a = null;
			}
			else if(a !== null && !Type.isClassInstance(a, ClassA)) {
				throw new TypeError("'a' is not of type 'ClassA?'");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.isClassInstance(b, ClassB)) {
				throw new TypeError("'b' is not of type 'ClassB'");
			}
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
				if(!Type.isNumber(e)) {
					throw new TypeError("'e' is not of type 'Number'");
				}
			}
			else {
				e = 0;
			}
			return 0;
		}
		else if((arguments.length >= 3 && arguments.length <= 5) || arguments.length === 6) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0) {
				a = null;
			}
			else if(a !== null && !Type.isClassInstance(a, ClassA)) {
				throw new TypeError("'a' is not of type 'ClassA?'");
			}
			let n = arguments[++__ks_i];
			if(n === void 0) {
				n = null;
			}
			else if(n !== null && !Type.isString(n)) {
				throw new TypeError("'n' is not of type 'String?'");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.isClassInstance(b, ClassB)) {
				throw new TypeError("'b' is not of type 'ClassB'");
			}
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
				if(!Type.isNumber(e)) {
					throw new TypeError("'e' is not of type 'Number'");
				}
			}
			else {
				e = 0;
			}
			return 1;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};