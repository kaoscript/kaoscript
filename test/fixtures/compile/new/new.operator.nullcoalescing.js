var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
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
	const $map = (() => {
		const d = new Dictionary();
		d.default = Foobar;
		d.foobar = Foobar;
		return d;
	})();
	function foobar(name) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		const clazz = Type.isValue($map[name]) ? $map[name] : $map.default;
		return new clazz();
	}
};