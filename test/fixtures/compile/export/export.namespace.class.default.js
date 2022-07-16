const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
			return foo.__ks_rt(this, arguments);
		};
		foo.__ks_0 = function() {
		};
		foo.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return foo.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		function bar() {
			return bar.__ks_rt(this, arguments);
		};
		bar.__ks_0 = function() {
		};
		bar.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return bar.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		function qux() {
			return qux.__ks_rt(this, arguments);
		};
		qux.__ks_0 = function() {
		};
		qux.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return qux.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		class Foobar {
			static __ks_new_0() {
				const o = Object.create(Foobar.prototype);
				o.__ks_init();
				return o;
			}
			constructor() {
				this.__ks_init();
				this.__ks_cons_rt.call(null, this, arguments);
			}
			__ks_init() {
				this._name = "";
			}
			__ks_cons_rt(that, args) {
				if(args.length !== 0) {
					throw Helper.badArgs();
				}
			}
			name() {
				return this.__ks_func_name_rt.call(null, this, this, arguments);
			}
			__ks_func_name_0() {
				return this._name;
			}
			__ks_func_name_1(name) {
				this._name = name;
				return this;
			}
			__ks_func_name_rt(that, proto, args) {
				const t0 = Type.isString;
				if(args.length === 0) {
					return proto.__ks_func_name_0.call(that);
				}
				if(args.length === 1) {
					if(t0(args[0])) {
						return proto.__ks_func_name_1.call(that, args[0]);
					}
				}
				throw Helper.badArgs();
			}
		}
		return {
			Foobar,
			foo,
			bar,
			qux
		};
	});
	return {
		NS
	};
};