var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let qux = Helper.namespace(function() {
		class Foobar {
			constructor() {
				this.__ks_init();
				this.__ks_cons(arguments);
			}
			__ks_init() {
			}
			__ks_cons_0(name) {
				if(name === void 0 || name === null) {
					name = "john";
				}
				else if(!Type.isString(name)) {
					throw new TypeError("'name' is not of type 'String'");
				}
				this._name = name;
			}
			__ks_cons(args) {
				if(args.length >= 0 && args.length <= 1) {
					Foobar.prototype.__ks_cons_0.apply(this, args);
				}
				else {
					throw new SyntaxError("Wrong number of arguments");
				}
			}
		}
		return {
			Foobar: Foobar
		};
	});
	const x = new qux.Foobar();
};