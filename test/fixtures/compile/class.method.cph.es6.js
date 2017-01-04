var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class LetterBox {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(messages) {
			if(messages === undefined || messages === null) {
				throw new Error("Missing parameter 'messages'");
			}
			this._messages = messages;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				LetterBox.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_build_0() {
			return Helper.mapArray(this._messages, (message) => {
				return this.format(message);
			});
		}
		build() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_format_0(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			if(!Type.isString(message)) {
				throw new Error("Invalid type for parameter 'message'");
			}
			return message.toUpperCase();
		}
		format() {
			if(arguments.length === 1) {
				return LetterBox.prototype.__ks_func_format_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	LetterBox.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 1,
				max: 1,
				parameters: [
					{
						type: "Any",
						min: 1,
						max: 1
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {
			_messages: {
				access: 1,
				type: "Array"
			}
		},
		classVariables: {},
		instanceMethods: {
			build: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			],
			format: [
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: "String",
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {}
	};
}