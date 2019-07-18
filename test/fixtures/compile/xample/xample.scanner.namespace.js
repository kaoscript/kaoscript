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
			__ks_func_match_0(...tokens) {
				const c = this.skip(tokens.length);
				return Token.INVALID;
			}
			match() {
				return Scanner.prototype.__ks_func_match_0.apply(this, arguments);
			}
			__ks_func_skip_0(index) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
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