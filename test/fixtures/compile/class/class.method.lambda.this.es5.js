module.exports = function() {
	class Formatter {
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
		__ks_func_camelize_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			return this.toLowerCase(value.charAt(0)) + value.substr(1).replace(/[-_\s]+(.)/g, (function(__ks_0, l) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(l === void 0 || l === null) {
					throw new TypeError("'l' is not nullable");
				}
				return this.toUpperCase(l);
			}).bind(this));
		}
		camelize() {
			if(arguments.length === 1) {
				return Formatter.prototype.__ks_func_camelize_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_toLowerCase_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			return value.toLowerCase();
		}
		toLowerCase() {
			if(arguments.length === 1) {
				return Formatter.prototype.__ks_func_toLowerCase_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_toUpperCase_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			return value.toUpperCase();
		}
		toUpperCase() {
			if(arguments.length === 1) {
				return Formatter.prototype.__ks_func_toUpperCase_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	const formatter = new Formatter();
	console.log(formatter.camelize("john doe"));
};