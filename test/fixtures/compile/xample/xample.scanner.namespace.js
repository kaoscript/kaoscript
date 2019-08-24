var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let Parser = (function() {
		let Token = {
			INVALID: 0
		};
		class Scanner {
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
			__ks_func_match_0() {
				let __ks_i = -1;
				let tokens = [];
				while(arguments.length > ++__ks_i) {
					if(Type.isArray(arguments[__ks_i], Token)) {
						tokens.push(arguments[__ks_i]);
					}
					else {
						throw new TypeError("'tokens' is not of type 'Array'");
					}
				}
				const c = this.skip(tokens.length);
				return Token.INVALID;
			}
			match() {
				return Scanner.prototype.__ks_func_match_0.apply(this, arguments);
			}
			__ks_func_skip_0(index) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(index === void 0 || index === null) {
					throw new TypeError("'index' is not nullable");
				}
			}
			skip() {
				if(arguments.length === 1) {
					return Scanner.prototype.__ks_func_skip_0.apply(this, arguments);
				}
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		return {};
	})();
	return {
		Parser: Parser
	};
};