var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Error = {};
	let Exception = Helper.class({
		$name: "Exception",
		$extends: Error,
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_1: function() {
			this.fileName = null;
			this.lineNumber = 0;
		},
		__ks_init: function() {
			Exception.prototype.__ks_init_1.call(this);
		},
		__ks_cons_0: function(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			(1);
			this.message = message;
			this.name = this.constructor.name;
		},
		__ks_cons_1: function(message, fileName, lineNumber) {
			if(arguments.length < 3) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			if(fileName === void 0) {
				fileName = null;
			}
			else if(fileName !== null && !Type.isString(fileName)) {
				throw new TypeError("'fileName' is not of type 'String'");
			}
			if(lineNumber === void 0 || lineNumber === null) {
				throw new TypeError("'lineNumber' is not nullable");
			}
			else if(!Type.isNumber(lineNumber)) {
				throw new TypeError("'lineNumber' is not of type 'Number'");
			}
			Exception.prototype.__ks_cons.call(this, [message]);
			this.fileName = fileName;
			this.lineNumber = lineNumber;
		},
		__ks_cons: function(args) {
			if(args.length === 1) {
				Exception.prototype.__ks_cons_0.apply(this, args);
			}
			else if(args.length === 3) {
				Exception.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	});
};