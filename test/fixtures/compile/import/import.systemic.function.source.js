require("kaoscript/register");
module.exports = function() {
	var __ks_Function = require("../_/_function.ks")().__ks_Function;
	class Template {
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
		__ks_func_compile_0() {
			return function() {
				return 42;
			};
		}
		compile() {
			if(arguments.length === 0) {
				return Template.prototype.__ks_func_compile_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_run_0(...args) {
		}
		run() {
			return Template.prototype.__ks_func_run_0.apply(this, arguments);
		}
	}
	const template = new Template();
	return {
		Template: Template,
		template: template
	};
};