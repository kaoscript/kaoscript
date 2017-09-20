var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Message {
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
		static __ks_sttc_build_0(...lines) {
			return lines.join("\n");
		}
		static build() {
			return Message.__ks_sttc_build_0.apply(this, arguments);
		}
	}
	const hello = Helper.vcurry(Message.build, null, "Hello!");
	function print(name, printer) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		if(printer === void 0 || printer === null) {
			throw new TypeError("'printer' is not nullable");
		}
		else if(!Type.isFunction(printer)) {
			throw new TypeError("'printer' is not of type 'Function'");
		}
		return printer("It's nice to meet you, ", name, ".");
	}
	print("miss White", hello);
};