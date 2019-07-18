module.exports = function() {
	let NS = (function() {
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
		function foo() {
			return "42";
		}
		return {
			Foobar: Foobar
		};
	})();
	function foo() {
		return "42";
	}
	return {
		NS: NS
	};
};