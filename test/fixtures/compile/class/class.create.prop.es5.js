var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Writer = Helper.class({
		$name: "Writer",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons_0: function(Line) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(Line === void 0 || Line === null) {
				throw new TypeError("'Line' is not nullable");
			}
			else if(!Type.isClass(Line)) {
				throw new TypeError("'Line' is not of type 'Class'");
			}
			this.Line = Line;
		},
		__ks_cons: function(args) {
			if(args.length === 1) {
				Writer.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		},
		__ks_func_newLine_0: function() {
			let args = Array.prototype.slice.call(arguments, 0, arguments.length);
			return Helper.create(this.Line, args);
		},
		newLine: function() {
			return Writer.prototype.__ks_func_newLine_0.apply(this, arguments);
		}
	});
};