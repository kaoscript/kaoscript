var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
		}
		function bar() {
		}
		function qux() {
		}
		class Foobar {
			constructor() {
				this.__ks_init();
				this.__ks_cons(arguments);
			}
			__ks_init_1() {
				this._name = "";
			}
			__ks_init() {
				Foobar.prototype.__ks_init_1.call(this);
			}
			__ks_cons(args) {
				if(args.length !== 0) {
					throw new SyntaxError("Wrong number of arguments");
				}
			}
			__ks_func_name_0() {
				return this._name;
			}
			__ks_func_name_1(name) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(name === void 0 || name === null) {
					throw new TypeError("'name' is not nullable");
				}
				else if(!Type.isString(name)) {
					throw new TypeError("'name' is not of type 'String'");
				}
				this._name = name;
				return this;
			}
			name() {
				if(arguments.length === 0) {
					return Foobar.prototype.__ks_func_name_0.apply(this);
				}
				else if(arguments.length === 1) {
					return Foobar.prototype.__ks_func_name_1.apply(this, arguments);
				}
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		return {
			foo: foo,
			bar: bar,
			qux: qux,
			Foobar: Foobar
		};
	});
	const $available = [];
	function acquire() {
		if($available.length === 0) {
			return new NS.Foobar();
		}
		else {
			return $available.pop();
		}
	}
	function release(item) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		else if(!Type.isClassInstance(item, NS.Foobar)) {
			throw new TypeError("'item' is not of type 'Foobar'");
		}
		$available.push(item);
	}
	return {
		NS: NS,
		acquire: acquire,
		release: release
	};
};