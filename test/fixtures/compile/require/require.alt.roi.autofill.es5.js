require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var Color = Helper.class({
		$name: "Color",
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
		}
	});
	var Color = require("./require.default.ks")(Color).Color;
	var c = new Color();
};