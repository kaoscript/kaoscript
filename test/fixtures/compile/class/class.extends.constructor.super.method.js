var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var Master = Helper.class({
		$name: "Master",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_name_0: function() {
			return "Master";
		},
		name: function() {
			if(arguments.length === 0) {
				return Master.prototype.__ks_func_name_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
	var Subby = Helper.class({
		$name: "Subby",
		$extends: Master,
		__ks_init: function() {
			Master.prototype.__ks_init.call(this);
		},
		__ks_cons_0: function() {
			Master.prototype.__ks_cons.call(this, []);
			var name = Master.prototype.name.apply(this, []);
		},
		__ks_cons: function(args) {
			if(args.length === 0) {
				Subby.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_name_0: function() {
			return "Subby";
		},
		name: function() {
			if(arguments.length === 0) {
				return Subby.prototype.__ks_func_name_0.apply(this);
			}
			return Master.prototype.name.apply(this, arguments);
		}
	});
};