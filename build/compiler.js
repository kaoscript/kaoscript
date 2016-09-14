module.exports = function() {
	var {Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type} = require("@kaoscript/runtime")();
	var {AssignmentOperator, BinaryOperator, ClassModifier, FunctionModifier, Kind, MemberModifier, ParameterModifier, ScopeModifier, UnaryOperator, VariableModifier} = require("@kaoscript/ast")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type);
	var fs = require("../src/fs.js");
	var parse = require("@kaoscript/parser").parse;
	var path = require("path");
	Class.newInstanceMethod({
		class: Array,
		name: "append",
		final: __ks_Array,
		function: function(...args) {
			if(args.length === 1) {
				this.push.apply(this, __ks_Array._cm_from(args[0]));
			}
			else {
				for(var i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
					this.push.apply(this, __ks_Array._cm_from(args[i]));
				}
			}
			return this;
		},
		signature: {
			access: 3,
			min: 1,
			max: Infinity,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: Infinity
				}
			]
		}
	});
	Class.newInstanceMethod({
		class: Array,
		name: "appendUniq",
		final: __ks_Array,
		function: function(...args) {
			if(args.length === 1) {
				__ks_Array._im_pushUniq.apply(__ks_Array, [this].concat(args[0]));
			}
			else {
				for(var i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
					__ks_Array._im_pushUniq.apply(__ks_Array, [this].concat(__ks_Array._cm_from(args[i])));
				}
			}
			return this;
		},
		signature: {
			access: 3,
			min: 1,
			max: Infinity,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: Infinity
				}
			]
		}
	});
	Class.newInstanceMethod({
		class: Array,
		name: "contains",
		final: __ks_Array,
		function: function() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var item = arguments[++__ks_i];
			if(arguments.length > 1) {
				var from = arguments[++__ks_i];
			}
			else  {
				var from = 0;
			}
			return this.indexOf(item, from) !== -1;
		},
		signature: {
			access: 3,
			min: 1,
			max: 2,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 2
				}
			]
		}
	});
	Class.newClassMethod({
		class: Array,
		name: "from",
		final: __ks_Array,
		function: function(item) {
			if(item === undefined || item === null) {
				throw new Error("Missing parameter 'item'");
			}
			if(Type.isEnumerable(item) && !Type.isString(item)) {
				return (Type.isArray(item)) ? (item) : (Array.prototype.slice.call(item));
			}
			else {
				return [item];
			}
		},
		signature: {
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
	});
	Class.newInstanceMethod({
		class: Array,
		name: "last",
		final: __ks_Array,
		function: function(index) {
			if(index === undefined || index === null) {
				index = 1;
			}
			return (this.length) ? (this[this.length - index]) : (null);
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	Class.newInstanceMethod({
		class: Array,
		name: "pushUniq",
		final: __ks_Array,
		function: function(...args) {
			if(args.length === 1) {
				if(!__ks_Array._im_contains(this, args[0])) {
					this.push(args[0]);
				}
			}
			else {
				for(var __ks_0 = 0, __ks_1 = args.length, item; __ks_0 < __ks_1; ++__ks_0) {
					item = args[__ks_0];
					if(!__ks_Array._im_contains(this, item)) {
						this.push(item);
					}
				}
			}
			return this;
		},
		signature: {
			access: 3,
			min: 1,
			max: Infinity,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: Infinity
				}
			]
		}
	});
	Class.newClassMethod({
		class: Object,
		name: "clone",
		final: __ks_Object,
		function: function(object) {
			if(object === undefined || object === null) {
				throw new Error("Missing parameter 'object'");
			}
			if((Type.isFunction(object.constructor.clone)) && (object.constructor.clone !== this)) {
				return object.constructor.clone(object);
			}
			if(Type.isFunction(object.constructor.prototype.clone)) {
				return object.clone();
			}
			var clone = {};
			for(var key in object) {
				var value = object[key];
				if(Type.isArray(value)) {
					clone[key] = value.clone();
				}
				else if(Type.isObject(value)) {
					clone[key] = __ks_Object._cm_clone(value);
				}
				else {
					clone[key] = value;
				}
			}
			return clone;
		},
		signature: {
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
	});
	var MemberAccess = {
		Private: 1,
		Protected: 2,
		Public: 3
	};
	var Mode = {
		Assignment: 1 << 0,
		Declaration: 1 << 1,
		Variable: 1 << 2,
		Key: 1 << 3,
		PrepareAll: 1 << 4,
		NoIndent: 1 << 5,
		Statement: 1 << 6,
		NoLine: 1 << 7,
		Operand: 1 << 8,
		PrepareNone: 1 << 9,
		NoRest: 1 << 10,
		IndentBlock: 1 << 11,
		Await: 1 << 12,
		Async: 1 << 13,
		BooleanExpression: 1 << 14,
		ObjectMember: 1 << 15
	};
	var VariableKind = {
		Class: 1,
		Enum: 2,
		Function: 3,
		TypeAlias: 4,
		Variable: 5
	};
	var $defaultTypes = {
		Array: "Array",
		Boolean: "Boolean",
		Function: "Function",
		Number: "Number",
		Object: "Object",
		String: "String"
	};
	var $extensions = {
		binary: ".ksb",
		hash: ".ksh",
		metadata: ".ksm",
		source: ".ks"
	};
	var $generics = {
		Array: true
	};
	var $literalTypes = {
		false: "Boolean",
		Infinity: "Number",
		NaN: "Number",
		true: "Boolean"
	};
	var $nodeModules = {
		assert: true,
		buffer: true,
		child_process: true,
		cluster: true,
		constants: true,
		crypto: true,
		dgram: true,
		dns: true,
		domain: true,
		events: true,
		fs: true,
		http: true,
		https: true,
		net: true,
		os: true,
		path: true,
		punycode: true,
		querystring: true,
		readline: true,
		repl: true,
		stream: true,
		string_decoder: true,
		tls: true,
		tty: true,
		url: true,
		util: true,
		v8: true,
		vm: true,
		zlib: true
	};
	var $predefined = {
		false: 1,
		null: 1,
		string: 1,
		true: 1,
		Error: 1,
		Function: 1,
		Infinity: 1,
		Math: 1,
		NaN: 1,
		Object: 1,
		String: 1,
		Type: 1
	};
	var $types = {
		any: "Any",
		array: "Array",
		bool: "Boolean",
		class: "Class",
		enum: "Enum",
		func: "Function",
		number: "Number",
		object: "Object",
		string: "String"
	};
	var $typekinds = {
		"Class": VariableKind.Class,
		"Enum": VariableKind.Enum,
		"Function": VariableKind.Function
	};
	var $typeofs = {
		Array: "Type.isArray",
		Boolean: "Type.isBoolean",
		Function: "Type.isFunction",
		NaN: "isNaN",
		Number: "Type.isNumber",
		Object: "Type.isObject",
		String: "Type.isString"
	};
	function $caller(data) {
		if(data === undefined || data === null) {
			throw new Error("Missing parameter 'data'");
		}
		if(data.kind === Kind.MemberExpression) {
			return data.object;
		}
		else {
			console.error(data);
			throw new Error("Not Implemented");
		}
	}
	function $class(data, variable, node) {
		if(data === undefined || data === null) {
			throw new Error("Missing parameter 'data'");
		}
		if(variable === undefined || variable === null) {
			throw new Error("Missing parameter 'variable'");
		}
		if(node === undefined || node === null) {
			throw new Error("Missing parameter 'node'");
		}
		var __ks_0 = data.kind;
		if(__ks_0 === Kind.CommentBlock) {
		}
		else if(__ks_0 === Kind.CommentLine) {
		}
		else if(__ks_0 === Kind.FieldDeclaration) {
			var instance = true;
			for(var i = 0, __ks_1 = data.modifiers.length; instance && i < __ks_1; ++i) {
				if(data.modifiers[i].kind === MemberModifier.Static) {
					instance = false;
				}
			}
			if(instance) {
				variable.instanceVariables[data.name.name] = $field.prepare(data, node);
			}
			else {
				variable.classVariables[data.name.name] = $field.prepare(data, node);
			}
		}
		else if(__ks_0 === Kind.MethodDeclaration) {
			if(data.name.name === variable.name.name) {
				$method.prepare(data, variable.constructors, node);
			}
			else {
				var instance = true;
				for(var i = 0, __ks_1 = data.modifiers.length; instance && i < __ks_1; ++i) {
					if(data.modifiers[i].kind === MemberModifier.Static) {
						instance = false;
					}
				}
				if(instance) {
					$method.prepare(data, variable.instanceMethods[data.name.name] || ((variable.instanceMethods[data.name.name] = [])), node);
				}
				else {
					$method.prepare(data, variable.classMethods[data.name.name] || ((variable.classMethods[data.name.name] = [])), node);
				}
			}
		}
		else {
			console.error(data);
			throw new Error("Unknow kind " + data.kind);
		}
	}
	function $compile() {
		if(arguments.length < 4) {
			throw new Error("Wrong number of arguments");
		}
		var __ks_i = -1;
		var node = arguments[++__ks_i];
		var data = arguments[++__ks_i];
		var config = arguments[++__ks_i];
		var mode = arguments[++__ks_i];
		if(arguments.length > 4) {
			var variable = arguments[++__ks_i];
		}
		else  {
			var variable = null;
		}
		if(data.attributes && data.attributes.length) {
			var __ks_0 = data.attributes;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, attr; __ks_1 < __ks_2; ++__ks_1) {
				attr = __ks_0[__ks_1];
				if((attr.declaration.kind === Kind.AttributeExpression) && (attr.declaration.name.name === "cfg")) {
					config = __ks_Object._cm_clone(config);
					var __ks_3 = attr.declaration.arguments;
					for(var __ks_4 = 0, __ks_5 = __ks_3.length, arg; __ks_4 < __ks_5; ++__ks_4) {
						arg = __ks_3[__ks_4];
						if(arg.kind === Kind.AttributeOperator) {
							config[arg.name.name] = arg.value.value;
						}
					}
				}
			}
		}
		var __ks_0 = data.kind;
		if(__ks_0 === Kind.ArrayBinding) {
			node.code("[");
			for(var i = 0, __ks_1 = data.elements.length; i < __ks_1; ++i) {
				if(i) {
					node.code(", ");
				}
				node.compile(data.elements[i], config, mode | Mode.Key);
			}
			node.code("]");
		}
		else if(__ks_0 === Kind.ArrayComprehension) {
			if(data.loop.kind === Kind.ForInStatement) {
				node.code("__ks_Array._cm_map(").compile(data.loop.value, config).code(", ");
				var ctrl = node.newControl().addMode(Mode.NoIndent).code("(").parameter(data.loop.variable, config);
				if(data.loop.index) {
					ctrl.code(", ").parameter(data.loop.index, config);
				}
				ctrl.code(") =>").step().newExpression().code("return ").compile(data.body, config);
				if(data.loop.when) {
					node.code(", ");
					ctrl = node.newControl().addMode(Mode.NoIndent).code("(").parameter(data.loop.variable, config);
					if(data.loop.index) {
						ctrl.code(", ").parameter(data.loop.index, config);
					}
					ctrl.code(") =>").step().newExpression().code("return ").compile(data.loop.when, config);
				}
				node.code(")");
			}
			else if(data.loop.kind === Kind.ForOfStatement) {
				node.code("__ks_Object._cm_map(").compile(data.loop.value, config).code(", ");
				var ctrl = node.newControl().addMode(Mode.NoIndent).code("(").parameter(data.loop.variable, config);
				if(data.loop.index) {
					ctrl.code(", ").parameter(data.loop.index, config);
				}
				ctrl.code(") =>").step().newExpression().code("return ").compile(data.body, config);
				if(data.loop.when) {
					node.code(", ");
					ctrl = node.newControl().addMode(Mode.NoIndent).code("(").parameter(data.loop.variable, config);
					if(data.loop.index) {
						ctrl.code(", ").parameter(data.loop.index, config);
					}
					ctrl.code(") =>").step().newExpression().code("return ").compile(data.loop.when, config);
				}
				node.code(")");
			}
			else if(data.loop.kind === Kind.ForRangeStatement) {
				node.code("__ks_Array._cm_map(").code("Array_Integer.range(").compile(data.loop.from, config).code(", ").compile(data.loop.to, config);
				if(data.loop.by) {
					node.code(", ").compile(data.loop.by, config);
				}
				node.code("), ").newControl().addMode(Mode.NoIndent).code("(").parameter(data.loop.variable, config).code(") =>").step().newExpression().code("return ").compile(data.body, config);
				if(data.loop.when) {
					node.code(", ");
					node.newControl().addMode(Mode.NoIndent).code("(").parameter(data.loop.variable, config).code(") =>").step().newExpression().code("return ").compile(data.loop.when, config);
				}
				node.code(")");
			}
			else {
				console.error(data);
				throw new Error("Not Implemented");
			}
		}
		else if(__ks_0 === Kind.ArrayExpression) {
			node.code("[");
			for(var i = 0, __ks_1 = data.values.length; i < __ks_1; ++i) {
				if(i) {
					node.code(", ");
				}
				node.compile(data.values[i], config);
			}
			node.code("]");
		}
		else if(__ks_0 === Kind.ArrayRange) {
			node.code("_ks_Array._cm_range(").compile(data.from || data.then, config).code(", ").compile(data.to || data.til, config);
			if(data.by) {
				node.code(", ").compile(data.by, config);
			}
			else {
				node.code(", 1");
			}
			node.code(", ", !!data.from, ", ", !!data.to, ")");
		}
		else if(__ks_0 === Kind.AwaitExpression) {
			var ctrl = node.newExpression().newControl().addMode(Mode.NoIndent);
			ctrl.compile(data.operation, config, Mode.Await);
			ctrl.code("(__ks_e");
			var __ks_1 = data.variables;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length; __ks_2 < __ks_3; ++__ks_2) {
				variable = __ks_1[__ks_2];
				ctrl.code(", ").parameter(variable.name, config, variable.type);
			}
			ctrl.code(") =>").step();
			ctrl.newControl().code("if(__ks_e)").step().newExpression().code("return __ks_cb(__ks_e)");
			return {
				node: ctrl,
				mode: Mode.Async,
				close(node) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					node.step().addMode(Mode.NoLine).code(")");
				}
			};
		}
		else if(__ks_0 === Kind.BinaryOperator) {
			var exp = node.newExpression();
			if(mode & Mode.Operand) {
				exp.code("(");
			}
			if(data.operator.kind === BinaryOperator.Assignment) {
				$operator.assignment(exp, data, config, mode);
			}
			else {
				$operator.binary(exp, data, config, mode);
			}
			if(mode & Mode.Operand) {
				exp.code(")");
			}
		}
		else if(__ks_0 === Kind.BindingElement) {
			if(data.spread) {
				node.code("...");
			}
			if(data.alias) {
				if(data.alias.computed) {
					node.code("[").compile(data.alias, config, mode).code("]: ");
				}
				else {
					node.compile(data.alias, config, mode).code(": ");
				}
			}
			node.compile(data.name, config, mode);
			$variable.define(node, data.name, VariableKind.Variable);
			if(data.defaultValue) {
				node.code(" = ").compile(data.defaultValue, config, mode);
			}
		}
		else if(__ks_0 === Kind.Block) {
			node = node.newBlock();
			var stack = [];
			var r;
			for(var i = 0, __ks_1 = data.statements.length; i < __ks_1; ++i) {
				if(((r = node.compile(data.statements[i], config, mode))) && r.node && r.close) {
					node = r.node;
					mode = r.mode;
					stack.push(r);
				}
			}
			for(var __ks_1 = 0, __ks_2 = stack.length, item; __ks_1 < __ks_2; ++__ks_1) {
				item = stack[__ks_1];
				item.close(item.node);
			}
		}
		else if(__ks_0 === Kind.BreakStatement) {
			node.newExpression().code("break");
		}
		else if(__ks_0 === Kind.CallExpression) {
			var list = true;
			var __ks_1 = data.arguments;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, argument; list && __ks_2 < __ks_3; ++__ks_2) {
				argument = __ks_1[__ks_2];
				if((argument.kind === Kind.UnaryExpression) && (argument.operator.kind === UnaryOperator.Spread)) {
					list = false;
				}
			}
			node = node.newExpression();
			var callee;
			if((data.callee.kind === Kind.MemberExpression) && !data.callee.computed && (data.callee.object.kind === Kind.MemberExpression) && !data.callee.object.computed && (data.callee.property.kind === Kind.Identifier) && (data.callee.property.name === "apply") && ((callee = $final.callee(data.callee.object, node)))) {
				if(callee.variable) {
					if(data.callee.property.name === "apply") {
						node.code(callee.variable.accessPath || "", callee.variable.final.name, (callee.instance) ? ("._im_") : ("._cm_"), data.callee.object.property.name, ".apply(", callee.variable.accessPath || "", callee.variable.final.name, ", ");
						if(data.arguments.length === 1) {
							node.compile(data.arguments[0], config);
						}
						else if(data.arguments.length === 2) {
							if(data.arguments[1].kind === Kind.ArrayExpression) {
								node.code("[").compile(data.arguments[0], config);
								var __ks_2 = data.arguments[1].values;
								for(var __ks_3 = 0, __ks_4 = __ks_2.length, value; __ks_3 < __ks_4; ++__ks_3) {
									value = __ks_2[__ks_3];
									node.code(", ").compile(value, config);
								}
								node.code("]");
							}
							else {
								node.code("[").compile(data.arguments[0], config).code("].concat(").compile(data.arguments[1], config).code(")");
							}
						}
						else {
							throw new Error("Wrong number of arguments for apply() at line " + data.callee.property.start.line);
						}
						node.code(")");
					}
				}
				else {
					console.error(callee);
					throw new Error("Not Implemented");
				}
			}
			else if((data.callee.kind === Kind.MemberExpression) && !data.callee.computed && ((callee = $final.callee(data.callee, node)))) {
				if(callee.variable) {
					if(callee.instance) {
						node.code(callee.variable.accessPath || "", callee.variable.final.name, "._im_" + data.callee.property.name + "(").compile(data.callee.object, config);
						for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
							node.code(", ").compile(data.arguments[i], config);
						}
						if(mode & Mode.Await) {
							node.code(", ");
						}
						else {
							node.code(")");
						}
					}
					else {
						node.code(callee.variable.accessPath || "", callee.variable.final.name + "._cm_" + data.callee.property.name + "(");
						for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
							if(i) {
								node.code(", ");
							}
							node.compile(data.arguments[i], config);
						}
						if(mode & Mode.Await) {
							if(data.arguments.length) {
								node.code(", ");
							}
						}
						else {
							node.code(")");
						}
					}
				}
				else if(callee.variables.length === 2) {
					if(mode & Mode.Operand) {
						node.code("(");
					}
					var name = null;
					if(data.callee.object.kind === Kind.Identifier) {
						if($typeofs[callee.variables[0].name]) {
							node.code($typeofs[callee.variables[0].name], "(").compile(data.callee.object, config).code(")");
						}
						else {
							node.code("Type.is(").compile(data.callee.object, config).code(", ", callee.variables[0].name, ")");
						}
					}
					else {
						name = node.newTempName();
						if($typeofs[callee.variables[0].name]) {
							node.code($typeofs[callee.variables[0].name], "(", name, " = ").compile(data.callee.object, config).code(")");
						}
						else {
							node.code("Type.is(", name, " = ").compile(data.callee.object, config).code(", ", callee.variables[0].name, ")");
						}
					}
					node.code(" ? ");
					node.code(callee.variables[0].accessPath || "", callee.variables[0].final.name + "._im_" + data.callee.property.name + "(").compile((name) ? (name) : (data.callee.object), config);
					for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
						node.code(", ").compile(data.arguments[i], config);
					}
					node.code(") : ");
					node.code(callee.variables[1].accessPath || "", callee.variables[1].final.name + "._im_" + data.callee.property.name + "(").compile((name) ? (name) : (data.callee.object), config);
					for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
						node.code(", ").compile(data.arguments[i], config);
					}
					node.code(")");
					if(mode & Mode.Operand) {
						node.code(")");
					}
				}
				else {
					console.error(callee);
					throw new Error("Not Implemented");
				}
			}
			else {
				if(list) {
					if(data.scope.kind === ScopeModifier.This) {
						var __ks_variable_1 = data.callee.kind === Kind.Identifier ? node.getVariable(data.callee.name) : undefined;
						if(__ks_variable_1 && __ks_variable_1.callReplacement) {
							__ks_variable_1.callReplacement(node, data, list);
						}
						else {
							node.compile(data.callee, config).code("(");
							for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
								if(i) {
									node.code(", ");
								}
								node.compile(data.arguments[i], config);
							}
							if(mode & Mode.Await) {
								if(data.arguments.length) {
									node.code(", ");
								}
							}
							else {
								node.code(")");
							}
						}
					}
					else {
						console.error(data);
						throw new Error("Not Implemented");
					}
				}
				else if(data.arguments.length === 1) {
					node.compile(data.callee, config).code(".apply(");
					if(data.scope.kind === ScopeModifier.Null) {
						node.code("null");
					}
					else if(data.scope.kind === ScopeModifier.This) {
						var caller = $caller(data.callee);
						if(caller) {
							node.compile(caller, config);
						}
						else {
							node.code("null");
						}
					}
					else {
						node.compile(data.scope.value, config);
					}
					node.code(", ").compile(data.arguments[0].argument, config);
					if(mode & Mode.Await) {
						node.code(", ");
					}
					else {
						node.code(")");
					}
				}
				else {
					console.error(data);
					throw new Error("Not Implemented");
				}
			}
		}
		else if(__ks_0 === Kind.ClassDeclaration) {
			variable = $variable.define(node, data.name, VariableKind.Class, data.type);
			if(variable.new) {
				for(var i = 0, __ks_1 = data.members.length; i < __ks_1; ++i) {
					$class(data.members[i], variable, node);
				}
				var continuous = true;
				for(var i = 0, __ks_1 = data.modifiers.length; continuous && i < __ks_1; ++i) {
					if(data.modifiers[i].kind === ClassModifier.Final) {
						continuous = false;
					}
				}
				if(continuous) {
					$continuous.class(node, data, config, mode, variable);
				}
				else {
					variable.final = {
						constructors: false,
						instanceMethods: {},
						classMethods: {}
					};
					$final.class(node, data, config, mode, variable);
				}
			}
			else {
				console.error(data);
				throw new Error("Not Implemented");
			}
		}
		else if(__ks_0 === Kind.CommentBlock) {
		}
		else if(__ks_0 === Kind.CommentLine) {
		}
		else if(__ks_0 === Kind.ContinueStatement) {
			node.newExpression().code("continue");
		}
		else if(__ks_0 === Kind.CurryExpression) {
			var list = true;
			var __ks_1 = data.arguments;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, argument; list && __ks_2 < __ks_3; ++__ks_2) {
				argument = __ks_1[__ks_2];
				if((argument.kind === Kind.UnaryExpression) && (argument.operator.kind === UnaryOperator.Spread)) {
					list = false;
				}
			}
			node = node.newExpression();
			if(list) {
				if(data.scope.kind === ScopeModifier.Null) {
					node.code("__ks_Function._cm_vcurry(").compile(data.callee, config).code(", null");
					for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
						node.code(", ").compile(data.arguments[i], config);
					}
					node.code(")");
				}
				else if(data.scope.kind === ScopeModifier.This) {
					node.code("__ks_Function._cm_vcurry(").compile(data.callee, config).code(", ");
					var caller = $caller(data.callee);
					if(caller) {
						node.compile(caller, config);
					}
					else {
						node.code("null");
					}
					for(var i = 0, __ks_2 = data.arguments.length; i < __ks_2; ++i) {
						node.code(", ").compile(data.arguments[i], config);
					}
					node.code(")");
				}
				else {
					console.error(data);
					throw new Error("Not Implemented");
				}
			}
			else if(data.arguments.length === 1) {
				console.error(data);
				throw new Error("Not Implemented");
			}
			else {
				console.error(data);
				throw new Error("Not Implemented");
			}
		}
		else if(__ks_0 === Kind.DoUntilStatement) {
			node.newControl().code("do").step().compile(data.body, config).step().code("while(!(").compile(data.condition, config).code("))");
		}
		else if(__ks_0 === Kind.DoWhileStatement) {
			node.newControl().code("do").step().compile(data.body, config).step().code("while(").compile(data.condition, config).code(")");
		}
		else if(__ks_0 === Kind.EnumDeclaration) {
			variable = $variable.define(node, data.name, VariableKind.Enum, data.type);
			if(variable.new) {
				var statement = node.newExpression().code($variable.scope(config)).compile(variable.name, config, Mode.Key).code(" = {").indent();
				for(var i = 0, __ks_1 = data.members.length; i < __ks_1; ++i) {
					if(i) {
						statement.code(",");
					}
					statement.compile(data.members[i], config, 0, variable);
				}
				statement.unindent().newline().code("}");
			}
			else {
				for(var i = 0, __ks_1 = data.members.length; i < __ks_1; ++i) {
					node.compile(data.members[i], config, 0, variable);
				}
			}
		}
		else if(__ks_0 === Kind.EnumExpression) {
			node.compile(data.enum, config).code(".").compile(data.member, config, Mode.Key);
		}
		else if(__ks_0 === Kind.EnumMember) {
			if(variable.new) {
				node.newline().code(data.name.name, ": ", $variable.value(variable, data));
			}
			else {
				node.newExpression().code(variable.name.name || variable.name, ".", data.name.name, " = ", $variable.value(variable, data));
			}
		}
		else if(__ks_0 === Kind.ExportDeclaration) {
			var module = node.module();
			var __ks_1 = data.declarations;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, declaration; __ks_2 < __ks_3; ++__ks_2) {
				declaration = __ks_1[__ks_2];
				var __ks_4 = declaration.kind;
				if(__ks_4 === Kind.ClassDeclaration) {
					node.compile(declaration, config);
					module.export(declaration.name);
				}
				else if(__ks_4 === Kind.EnumDeclaration) {
					node.compile(declaration, config);
					module.export(declaration.name);
				}
				else if(__ks_4 === Kind.ExportAlias) {
					module.export(declaration.name, declaration.alias);
				}
				else if(__ks_4 === Kind.FunctionDeclaration) {
					node.compile(declaration, config);
					module.export(declaration.name);
				}
				else if(__ks_4 === Kind.Identifier) {
					module.export(declaration);
				}
				else if(__ks_4 === Kind.TypeAliasDeclaration) {
					$variable.define(node, declaration.name, VariableKind.TypeAlias, declaration.type);
					module.export(declaration.name);
				}
				else if(__ks_4 === Kind.VariableDeclaration) {
					node.compile(declaration, config);
					for(var j = 0, __ks_5 = declaration.declarations.length; j < __ks_5; ++j) {
						module.export(declaration.declarations[j].name);
					}
				}
				else {
					console.error(declaration);
					throw new Error("Not Implemented");
				}
			}
		}
		else if(__ks_0 === Kind.ExternDeclaration) {
			var __ks_1 = data.declarations;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, declaration; __ks_2 < __ks_3; ++__ks_2) {
				declaration = __ks_1[__ks_2];
				var __ks_4 = declaration.kind;
				if(__ks_4 === Kind.ClassDeclaration) {
					variable = $variable.define(node, declaration.name, VariableKind.Class, declaration);
					var continuous = true;
					for(var i = 0, __ks_5 = declaration.modifiers.length; continuous && i < __ks_5; ++i) {
						if(declaration.modifiers[i].kind === ClassModifier.Final) {
							continuous = false;
						}
					}
					if(!continuous) {
						variable.final = {
							constructors: false,
							instanceMethods: {},
							classMethods: {}
						};
					}
					for(var i = 0, __ks_5 = declaration.members.length; i < __ks_5; ++i) {
						$extern.classMember(declaration.members[i], variable, node);
					}
				}
				else if(__ks_4 === Kind.VariableDeclarator) {
					variable = $variable.define(node, declaration.name, $variable.kind(declaration.type), declaration.type);
				}
				else {
					console.error(declaration);
					throw new Error("Unknow kind " + declaration.kind);
				}
			}
		}
		else if(__ks_0 === Kind.ForFromStatement) {
			var ctrl = node.newControl();
			ctrl.code("for(", $variable.scope(config), data.variable.name, " = ").compile(data.from, config);
			var bound;
			if(data.til) {
				if(data.til.kind !== Kind.NumericExpression) {
					bound = ctrl.newTempName();
					ctrl.code(", ", bound, " = ").compile(data.til, config);
				}
			}
			else {
				if(data.to.kind !== Kind.NumericExpression) {
					bound = ctrl.newTempName();
					ctrl.code(", ", bound, " = ").compile(data.to, config);
				}
			}
			var by;
			if(data.by && !((data.by.kind === Kind.NumericExpression) || (data.by.kind === Kind.Identifier))) {
				by = ctrl.newTempName();
				ctrl.code(", ", by, " = ").compile(data.by, config);
			}
			ctrl.code("; ");
			if(data.until) {
				ctrl.code("!(").compile(data.until, config).code(") && ");
			}
			else if(data.while) {
				ctrl.compile(data.while, config).code(" && ");
			}
			ctrl.code(data.variable.name);
			var desc = (data.by && (data.by.kind === Kind.NumericExpression) && (data.by.value < 0)) || ((data.from.kind === Kind.NumericExpression) && ((data.to && (data.to.kind === Kind.NumericExpression) && (data.from.value > data.to.value)) || (data.til && (data.til.kind === Kind.NumericExpression) && (data.from.value > data.til.value))));
			if(data.til) {
				if(desc) {
					ctrl.code(" > ");
				}
				else {
					ctrl.code(" < ");
				}
				if(data.til.kind === Kind.NumericExpression) {
					ctrl.code(data.til.value);
				}
				else {
					ctrl.code(bound);
				}
			}
			else {
				if(desc) {
					ctrl.code(" >= ");
				}
				else {
					ctrl.code(" <= ");
				}
				if(data.to.kind === Kind.NumericExpression) {
					ctrl.code(data.to.value);
				}
				else {
					ctrl.code(bound);
				}
			}
			ctrl.code("; ");
			if(data.by) {
				if(data.by.kind === Kind.NumericExpression) {
					if(data.by.value === 1) {
						ctrl.code("++", data.variable.name);
					}
					else if(data.by.value === -1) {
						ctrl.code("--", data.variable.name);
					}
					else if(data.by.value >= 0) {
						ctrl.code(data.variable.name, " += ", data.by.value);
					}
					else {
						ctrl.code(data.variable.name, " -= ", -data.by.value);
					}
				}
				else if(data.by.kind === Kind.Identifier) {
					ctrl.code(data.variable.name, " += ").compile(data.by, config);
				}
				else {
					ctrl.code(data.variable.name, " += ", by);
				}
			}
			else if(desc) {
				ctrl.code("--", data.variable.name);
			}
			else {
				ctrl.code("++", data.variable.name);
			}
			ctrl.code(")").step();
			$variable.define(ctrl, data.variable, VariableKind.Variable);
			ctrl.compile(data.body, config);
		}
		else if(__ks_0 === Kind.ForInStatement) {
			var value;
			var index;
			var ctrl;
			var bound;
			if(data.value.kind === Kind.Identifier) {
				value = data.value.name;
			}
			else {
				value = node.newTempName();
				node.newExpression().code($variable.scope(config), value, " = ").compile(data.value, config);
			}
			if(data.desc) {
				if(data.index && node.hasVariable(data.index.name)) {
					index = data.index.name;
					node.newExpression().code(index, " = ", value, ".length - 1");
					ctrl = node.newControl().code("for(");
					if(!node.hasVariable(data.variable.name)) {
						ctrl.code($variable.scope(config), data.variable.name);
					}
				}
				else {
					ctrl = node.newControl();
					index = (data.index) ? (data.index.name) : (ctrl.newTempName());
					ctrl.code("for(", $variable.scope(config), index, " = ", value, ".length - 1");
					if(!node.hasVariable(data.variable.name)) {
						ctrl.code(", ", data.variable.name);
					}
				}
			}
			else {
				if(data.index && node.hasVariable(data.index.name)) {
					index = data.index.name;
					node.newExpression().code(index, " = 0");
					ctrl = node.newControl().code("for(", $variable.scope(config));
				}
				else {
					ctrl = node.newControl();
					index = (data.index) ? (data.index.name) : (ctrl.newTempName());
					ctrl.code("for(", $variable.scope(config), index, " = 0, ");
				}
				bound = ctrl.newTempName();
				ctrl.code(bound, " = ", value, ".length");
				if(!node.hasVariable(data.variable.name)) {
					ctrl.code(", ", data.variable.name);
				}
			}
			ctrl.code("; ");
			if(data.until) {
				ctrl.code("!(").compile(data.until, config).code(") && ");
			}
			else if(data.while) {
				ctrl.compile(data.while, config).code(" && ");
			}
			if(data.desc) {
				ctrl.code(index, " >= 0; --", index, ")").step();
			}
			else {
				ctrl.code(index, " < ", bound, "; ++", index, ")").step();
			}
			if(data.index) {
				$variable.define(ctrl, data.index, VariableKind.Variable);
			}
			ctrl.newExpression().code(data.variable.name, " = ", value, "[", index, "]");
			$variable.define(ctrl, data.variable.name, $variable.kind(data.variable.type), data.variable.type);
			if(data.when) {
				ctrl.newControl().code("if(").compile(data.when, config).code(")").step().compile(data.body, config);
			}
			else {
				ctrl.compile(data.body, config);
			}
		}
		else if(__ks_0 === Kind.ForOfStatement) {
			var value;
			if(data.value.kind === Kind.Identifier) {
				value = data.value.name;
			}
			else {
				value = node.newTempName();
				node.newExpression().code($variable.scope(config), value, " = ").compile(data.value, config);
			}
			var ctrl = node.newControl();
			ctrl.code("for(");
			if(!node.hasVariable(data.variable.name)) {
				ctrl.code($variable.scope(config));
			}
			ctrl.code(data.variable.name, " in ", value, ")");
			ctrl.step();
			$variable.define(ctrl, data.variable.name, $variable.kind(data.variable.type), data.variable.type);
			if(data.index) {
				if(!node.hasVariable(data.variable.name)) {
					ctrl.code($variable.scope(config));
				}
				ctrl.code(data.index.name, " = ", value, "[", data.variable.name, "]");
				$variable.define(ctrl, data.index, VariableKind.Variable);
			}
			if(data.until) {
				ctrl.newControl().code("if(").compile(data.until, config).code(")").step().newExpression().code("break");
			}
			else if(data.while) {
				ctrl.newControl().code("if(!(").compile(data.while, config).code("))").step().newExpression().code("break");
			}
			ctrl.compile(data.body, config);
		}
		else if(__ks_0 === Kind.ForRangeStatement) {
			var ctrl = node.newControl();
			ctrl.code("for(", $variable.scope(config), data.variable.name, " = ").compile(data.from, config).code("; ");
			if(data.until) {
				ctrl.code("!(").compile(data.until, config).code(") && ");
			}
			else if(data.while) {
				ctrl.compile(data.while, config).code(" && ");
			}
			ctrl.code(data.variable.name, " <= ");
			if(data.to.kind === Kind.NumericExpression) {
				ctrl.code(data.to.value);
			}
			else {
				ctrl.code(data.to);
			}
			ctrl.code("; ");
			if(data.by) {
				ctrl.code(data.variable.name, " += ", data.by.value);
			}
			else {
				ctrl.code("++", data.variable.name);
			}
			$variable.define(ctrl, data.variable.name, VariableKind.Variable);
			ctrl.code(")").step().compile(data.body, config);
		}
		else if(__ks_0 === Kind.FunctionDeclaration) {
			variable = $variable.define(node, data.name, VariableKind.Function, data.type);
			var __ks_1 = data.modifiers;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, modifier; __ks_2 < __ks_3; ++__ks_2) {
				modifier = __ks_1[__ks_2];
				if(modifier.kind === FunctionModifier.Async) {
					variable.async = true;
				}
			}
			node.newFunction().operation(function(ctrl) {
				if(ctrl === undefined || ctrl === null) {
					throw new Error("Missing parameter 'ctrl'");
				}
				ctrl.code("function ", data.name.name, "(");
				$function.parameters(ctrl, data, config, function(node) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					node.code(")").step();
				});
				$variable.define(ctrl, {
					kind: Kind.Identifier,
					name: "this"
				}, VariableKind.Variable);
				if(data.body.kind === Kind.Block) {
					ctrl.compile(data.body, config);
				}
				else {
					ctrl.newExpression().code("return ").compile(data.body, config);
				}
			});
		}
		else if(__ks_0 === Kind.FunctionExpression) {
			node.newFunction().operation(function(ctrl) {
				if(ctrl === undefined || ctrl === null) {
					throw new Error("Missing parameter 'ctrl'");
				}
				ctrl.addMode(mode | Mode.NoIndent);
				if(mode & Mode.ObjectMember) {
					ctrl.code("(");
				}
				else {
					ctrl.code("function(");
				}
				$function.parameters(ctrl, data, config, function(node) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					ctrl.code(")").step();
					if(mode & Mode.IndentBlock) {
						ctrl.indent();
					}
				});
				if(data.body.kind === Kind.Block) {
					ctrl.compile(data.body, config);
				}
				else {
					ctrl.newExpression().code("return ").compile(data.body, config);
				}
			});
		}
		else if(__ks_0 === Kind.Identifier) {
			if(!((mode & Mode.Key) || $predefined[data.name])) {
				node.use(data);
				node.codeVariable(data);
			}
			else {
				node.code(data.name);
			}
		}
		else if(__ks_0 === Kind.IfExpression) {
			if(data.else) {
				node.newExpression().compile(data.condition, config, Mode.BooleanExpression).code(" ? ").compile(data.then, config).code(" : ").compile(data.else, config);
			}
			else if(mode & Mode.Assignment) {
				node.newExpression().compile(data.condition, config, Mode.BooleanExpression).code(" ? ").compile(data.then, config).code(" : undefined");
			}
			else {
				node.newControl(Mode.PrepareAll).code("if(").compile(data.condition, config, Mode.BooleanExpression).code(")").step().compile(data.then, config);
			}
		}
		else if(__ks_0 === Kind.IfStatement) {
			var ctrl = node.newControl();
			ctrl.code("if(").compile(data.condition, config, Mode.BooleanExpression).code(")").step().compile(data.then, config);
			if(data.elseifs) {
				var __ks_1 = data.elseifs;
				for(var __ks_2 = 0, __ks_3 = __ks_1.length, elseif; __ks_2 < __ks_3; ++__ks_2) {
					elseif = __ks_1[__ks_2];
					ctrl.step().code("else if(").compile(elseif.condition, config, Mode.BooleanExpression).code(")").step().compile(elseif.body, config);
				}
			}
			if(data.else) {
				ctrl.step().code("else").step().compile(data.else.body, config);
			}
		}
		else if(__ks_0 === Kind.ImplementDeclaration) {
			variable = node.getVariable(data.class.name);
			if(variable.kind !== VariableKind.Class) {
				throw new Error("Invalid class for impl at line " + data.start.line);
			}
			if(variable.final) {
				if(!variable.final.name) {
					variable.final.name = "__ks_" + variable.name.name;
					node.newExpression().code("var " + variable.final.name + " = {}");
				}
			}
			for(var i = 0, __ks_1 = data.members.length; i < __ks_1; ++i) {
				$implement(node, data.members[i], config, variable);
			}
		}
		else if(__ks_0 === Kind.ImportDeclaration) {
			var __ks_1 = data.declarations;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, declaration; __ks_2 < __ks_3; ++__ks_2) {
				declaration = __ks_1[__ks_2];
				node.compile(declaration, config);
			}
		}
		else if(__ks_0 === Kind.ImportDeclarator) {
			var module = node.module();
			$import.resolve(data, module.parent(), module, node);
		}
		else if(__ks_0 === Kind.Literal) {
			node.code($quote(data.value));
		}
		else if(__ks_0 === Kind.MemberExpression) {
			node = node.newExpression();
			node.compile(data.object, config, mode | Mode.Operand);
			if(data.computed) {
				node.code("[").compile(data.property, config).code("]");
			}
			else {
				node.code(".", data.property.name);
			}
		}
		else if(__ks_0 === Kind.NumericExpression) {
			node.code(data.value);
		}
		else if(__ks_0 === Kind.ObjectBinding) {
			node.code("{");
			for(var i = 0, __ks_1 = data.elements.length; i < __ks_1; ++i) {
				if(i) {
					node.code(", ");
				}
				node.compile(data.elements[i], config, mode | Mode.Key);
			}
			node.code("}");
		}
		else if(__ks_0 === Kind.ObjectExpression) {
			var obj = node.newObject();
			if(data.properties.length) {
				for(var i = 0, __ks_1 = data.properties.length; i < __ks_1; ++i) {
					obj.compile(data.properties[i], config);
				}
			}
		}
		else if(__ks_0 === Kind.ObjectMember) {
			if((data.name.kind === Kind.Identifier) || (data.name.kind === Kind.Literal)) {
				if(data.value.kind === Kind.FunctionExpression) {
					node.newExpression().reference((data.name.kind === Kind.Identifier) ? ("." + data.name.name) : ("[" + $quote(data.name.value) + "]")).compile(data.name, config, Mode.Key).compile(data.value, config, Mode.NoIndent | Mode.ObjectMember);
				}
				else {
					node.newExpression().reference((data.name.kind === Kind.Identifier) ? ("." + data.name.name) : ("[" + $quote(data.name.value) + "]")).compile(data.name, config, Mode.Key).code(": ").compile(data.value, config, Mode.NoIndent);
				}
			}
			else {
				var {block, reference} = node.block();
				block.newExpression().code(reference, "[").compile(data.name, config, Mode.Key).code("] = ").compile(data.value, config);
			}
		}
		else if(__ks_0 === Kind.OmittedExpression) {
			if(data.spread) {
				node.code("...");
			}
		}
		else if(__ks_0 === Kind.PolyadicOperator) {
			var exp = node.newExpression();
			if(mode & Mode.Operand) {
				exp.code("(");
				$operator.polyadic(exp, data, config, mode);
				exp.code(")");
			}
			else {
				$operator.polyadic(exp, data, config, mode);
			}
		}
		else if(__ks_0 === Kind.RegularExpression) {
			node.code(data.value);
		}
		else if(__ks_0 === Kind.RequireDeclaration) {
			var module = node.module();
			var type;
			var __ks_1 = data.declarations;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, declaration; __ks_2 < __ks_3; ++__ks_2) {
				declaration = __ks_1[__ks_2];
				var __ks_4 = declaration.kind;
				if(__ks_4 === Kind.VariableDeclarator) {
					$variable.define(node, declaration.name, type = $variable.kind(declaration.type), declaration.type);
					module.require(declaration.name.name, type);
				}
				else {
					console.error(declaration);
					throw new Error("Unknow kind " + declaration.kind);
				}
			}
		}
		else if(__ks_0 === Kind.ReturnStatement) {
			if(mode & Mode.Async) {
				if(data.value) {
					node.newExpression().code("return __ks_cb(null, ").compile(data.value, config).code(")");
				}
				else {
					node.newExpression().code("return __ks_cb()");
				}
			}
			else {
				if(data.value) {
					node.newExpression().code("return ").compile(data.value, config);
				}
				else {
					node.newExpression().code("return");
				}
			}
		}
		else if(__ks_0 === Kind.SwitchStatement) {
			var conditions = {};
			var filters = {};
			var condition;
			var name;
			var exp;
			var value;
			var __ks_1 = data.clauses;
			for(var clauseIdx = 0, __ks_2 = __ks_1.length, clause; clauseIdx < __ks_2; ++clauseIdx) {
				clause = __ks_1[clauseIdx];
				var __ks_3 = clause.conditions;
				for(var conditionIdx = 0, __ks_4 = __ks_3.length; conditionIdx < __ks_4; ++conditionIdx) {
					condition = __ks_3[conditionIdx];
					if(condition.kind === Kind.SwitchConditionArray) {
						if(!conditions[clauseIdx]) {
							conditions[clauseIdx] = {};
						}
						var nv = true;
						for(var i = 0, __ks_5 = condition.values.length; nv && i < __ks_5; ++i) {
							if(condition.values[i].kind !== Kind.OmittedExpression) {
								nv = false;
							}
						}
						if(!nv) {
							name = conditions[clauseIdx][conditionIdx] = node.newTempName();
							exp = node.newExpression().code($variable.scope(config), name, " = ([");
							var names = {};
							for(var i = 0, __ks_5 = condition.values.length; i < __ks_5; ++i) {
								if(i) {
									exp.code(", ");
								}
								if(condition.values[i].kind === Kind.OmittedExpression) {
									if(condition.values[i].spread) {
										exp.code("...");
									}
								}
								else {
									exp.code("__ks_", i);
								}
							}
							exp.code("]) => ");
							nv = false;
							var __ks_5 = condition.values;
							for(var i = 0, __ks_6 = __ks_5.length; i < __ks_6; ++i) {
								value = __ks_5[i];
								if(value.kind !== Kind.OmittedExpression) {
									if(nv) {
										exp.code(" && ");
									}
									else {
										nv = true;
									}
									if(value.kind === Kind.SwitchConditionRange) {
										exp.code("__ks_", i);
										if(value.from) {
											exp.code(" >= ").compile(value.from, config);
										}
										else {
											exp.code(" > ").compile(value.then, config);
										}
										exp.code(" && ");
										exp.code("__ks_", i);
										if(value.to) {
											exp.code(" <= ").compile(value.to, config);
										}
										else {
											exp.code(" < ").compile(value.til, config);
										}
									}
									else {
										exp.code("__ks_", i, " === ").compile(value, config);
									}
								}
							}
						}
					}
				}
				if(clause.filter && clause.bindings.length) {
					name = filters[clauseIdx] = node.newTempName();
					exp = node.newExpression().code($variable.scope(config), name, " = (");
					for(var i = 0, __ks_4 = clause.bindings.length; i < __ks_4; ++i) {
						if(i) {
							exp.code(", ");
						}
						exp.compile(clause.bindings[i], config);
					}
					exp.code(") => ").compile(clause.filter, config);
				}
			}
			if(data.expression.kind === Kind.Identifier) {
				name = data.expression.name;
			}
			else {
				name = node.newTempName();
				node.newExpression().code($variable.scope(config), name, " = ").compile(data.expression, config);
			}
			var ctrl = node.newControl();
			var we = false;
			var binding;
			var mm;
			var __ks_2 = data.clauses;
			for(var clauseIdx = 0, __ks_3 = __ks_2.length, clause; clauseIdx < __ks_3; ++clauseIdx) {
				clause = __ks_2[clauseIdx];
				if(clause.conditions.length) {
					if(we) {
						throw new Error("The default clause is before this clause");
					}
					if(clauseIdx) {
						ctrl.code("else if(");
					}
					else {
						ctrl.code("if(");
					}
					var __ks_4 = clause.conditions;
					for(var i = 0, __ks_5 = __ks_4.length; i < __ks_5; ++i) {
						condition = __ks_4[i];
						if(i) {
							ctrl.code(" || ");
						}
						if(condition.kind === Kind.SwitchConditionArray) {
							ctrl.code("(", $typeofs.Array, "(", name, ")");
							mm = $switch.length(condition.values);
							if(mm.min === mm.max) {
								if(mm.min !== Infinity) {
									ctrl.code(" && ", name, ".length === ", mm.min);
								}
							}
							else {
								ctrl.code(" && ", name, ".length >= ", mm.min);
								if(mm.max !== Infinity) {
									ctrl.code(" && ", name, ".length <= ", mm.max);
								}
							}
							if(conditions[clauseIdx][i]) {
								ctrl.code(" && ", conditions[clauseIdx][i], "(", name, ")");
							}
							ctrl.code(")");
						}
						else if(condition.kind === Kind.SwitchConditionEnum) {
							var __ks_variable_2 = node.getVariable(data.expression.name);
							if(!__ks_variable_2 || (__ks_variable_2.type.kind !== VariableKind.Enum)) {
								throw new Error("Switch condition is not an Enum at line " + condition.start.line);
							}
							ctrl.code(name, " === ").compile(__ks_variable_2.type.name, config).code(".").compile(condition.name, config, Mode.Key);
						}
						else if(condition.kind === Kind.SwitchConditionObject) {
							console.error(condition);
							throw new Error("Not Implemented");
						}
						else if(condition.kind === Kind.SwitchConditionRange) {
							if(clause.conditions.length > 1) {
								ctrl.code("(");
							}
							ctrl.code(name);
							if(condition.from) {
								ctrl.code(" >= ").compile(condition.from, config);
							}
							else {
								ctrl.code(" > ").compile(condition.then, config);
							}
							ctrl.code(" && ");
							ctrl.code(name);
							if(condition.to) {
								ctrl.code(" <= ").compile(condition.to, config);
							}
							else {
								ctrl.code(" < ").compile(condition.til, config);
							}
							if(clause.conditions.length > 1) {
								ctrl.code(")");
							}
						}
						else if(condition.kind === Kind.SwitchConditionType) {
							$type.check(ctrl, {
								kind: Kind.Identifier,
								name: name
							}, condition.type, config);
						}
						else {
							ctrl.code(name, " === ").compile(condition, config);
						}
					}
					$switch.test(clause, ctrl, name, filters[clauseIdx], true, config);
					ctrl.code(")").step();
					$switch.binding(clause, ctrl, name, config);
					ctrl.compile(clause.body, config).step();
				}
				else if(clause.bindings.length) {
					if(clauseIdx) {
						ctrl.code("else if(");
					}
					else {
						ctrl.code("if(");
					}
					$switch.test(clause, ctrl, name, filters[clauseIdx], false, config);
					ctrl.code(")").step();
					$switch.binding(clause, ctrl, name, config);
					ctrl.compile(clause.body, config).step();
				}
				else if(clause.filter) {
					console.error(clause);
					throw new Error("Not Implemented");
				}
				else {
					if(clauseIdx) {
						ctrl.code("else");
					}
					else {
						ctrl.code("if(true)");
					}
					we = true;
					ctrl.step().compile(clause.body, config).step();
				}
			}
		}
		else if(__ks_0 === Kind.TemplateExpression) {
			for(var i = 0, __ks_1 = data.elements.length; i < __ks_1; ++i) {
				if(i) {
					node.code(" + ");
				}
				node.compile(data.elements[i], config);
			}
		}
		else if(__ks_0 === Kind.TernaryConditionalExpression) {
			if(mode & Mode.Operand) {
				node.code("(").compile(data.condition, config).code(" ? ").compile(data.then, config, Mode.Operand).code(" : ").compile(data.else, config, Mode.Operand).code(")");
			}
			else {
				node.code("(").compile(data.condition, config).code(") ? (").compile(data.then, config).code(") : (").compile(data.else, config).code(")");
			}
		}
		else if(__ks_0 === Kind.ThrowStatement) {
			node.newExpression().code("throw ").compile(data.value, config);
		}
		else if(__ks_0 === Kind.TryStatement) {
			var finalizer = null;
			if(data.finalizer) {
				finalizer = node.newTempName();
				node.newExpression().code($variable.scope(config), finalizer, " = ").newControl().addMode(Mode.NoIndent).code("() =>").step().compile(data.finalizer, config);
			}
			var ctrl = node.newControl().code("try").step().compile(data.body, config);
			if(finalizer) {
				ctrl.newExpression().code(finalizer, "()");
			}
			ctrl.step();
			if(data.catchClauses.length) {
				var error = node.newTempName();
				ctrl.code("catch(", error, ")").step();
				$variable.define(ctrl, error, VariableKind.Variable);
				if(finalizer) {
					ctrl.newExpression().code(finalizer, "()");
				}
				var ifs = ctrl.newControl();
				var __ks_1 = data.catchClauses;
				for(var i = 0, __ks_2 = __ks_1.length, catchClause; i < __ks_2; ++i) {
					catchClause = __ks_1[i];
					if(i) {
						ifs.code("else ");
					}
					ifs.code("if(Type.is(", error, ", ").compile(catchClause.type, config).code(")").step();
					if(catchClause.binding) {
						ifs.newExpression().code($variable.scope(config), catchClause.binding.name, " = ", error);
						$variable.define(ctrl, catchClause.binding, VariableKind.Variable);
					}
					ifs.compile(catchClause.body, config).step();
				}
				if(data.catchClause) {
					ifs.code("else").step();
					if(data.catchClause.binding) {
						ifs.newExpression().code($variable.scope(config), data.catchClause.binding.name, " = ", error);
						$variable.define(ctrl, data.catchClause.binding, VariableKind.Variable);
					}
					ifs.compile(data.catchClause.body, config).step();
				}
			}
			else if(data.catchClause) {
				if(data.catchClause.binding) {
					ctrl.code("catch(", data.catchClause.binding.name, ")").step();
					$variable.define(ctrl, data.catchClause.binding, VariableKind.Variable);
				}
				else {
					ctrl.code("catch(", node.newTempName(), ")").step();
				}
				if(finalizer) {
					ctrl.newExpression().code(finalizer, "()");
				}
				ctrl.compile(data.catchClause.body, config);
			}
			else {
				ctrl.code("catch(", node.newTempName(), ")").step();
				if(finalizer) {
					ctrl.newExpression().code(finalizer, "()");
				}
			}
		}
		else if(__ks_0 === Kind.TypeAliasDeclaration) {
			$variable.define(node, data.name, VariableKind.TypeAlias, data.type);
		}
		else if(__ks_0 === Kind.TypeReference) {
			node.code($types[data.typeName.name] || data.typeName.name);
		}
		else if(__ks_0 === Kind.UnaryExpression) {
			$operator.unary(node.newExpression(), data, config, mode);
		}
		else if(__ks_0 === Kind.UnlessExpression) {
			if(data.else) {
				node.newExpression().compile(data.condition, config).code(" ? ").compile(data.else, config).code(" : ").compile(data.then, config);
			}
			else if(mode & Mode.Assignment) {
				node.newExpression().compile(data.condition, config).code(" ? undefined : ").compile(data.then, config);
			}
			else {
				node.newControl(Mode.PrepareAll).code("if(!(").compile(data.condition, config).code("))").step().compile(data.then, config);
			}
		}
		else if(__ks_0 === Kind.UnlessStatement) {
			node.newControl().code("if(!(").compile(data.condition, config).code("))").step().compile(data.then, config);
		}
		else if(__ks_0 === Kind.UntilStatement) {
			node.newControl().code("while(!(").compile(data.condition, config).code("))").step().compile(data.body, config);
		}
		else if(__ks_0 === Kind.VariableDeclaration) {
			if(data.declarations.length === 1) {
				return node.compile(data.declarations[0], config, mode, data.modifiers.kind);
			}
			else {
				for(var i = 0, __ks_1 = data.declarations.length; i < __ks_1; ++i) {
					node.compile(data.declarations[i], config, mode, data.modifiers.kind);
				}
			}
		}
		else if(__ks_0 === Kind.VariableDeclarator) {
			var exp = node.newExpression();
			if(data.name.kind === Kind.Identifier) {
				if(config.variables === "es6") {
					if(variable === VariableModifier.Let) {
						exp.code("let ");
					}
					else {
						exp.code("const ");
					}
				}
				else {
					exp.code("var ");
					node.rename(data.name.name);
				}
				exp.compile(data.name, config);
			}
			else {
				if((data.name.kind === Kind.ArrayBinding) || (data.name.kind === Kind.ObjectBinding) || (config.variables === "es5")) {
					exp.code("var ");
				}
				else {
					if(variable === VariableModifier.Let) {
						exp.code("let ");
					}
					else {
						exp.code("const ");
					}
				}
				exp.compile(data.name, config);
			}
			if(data.autotype) {
				var type = data.type;
				if(!type && data.init) {
					type = data.init;
				}
				$variable.define(exp, data.name, $variable.kind(data.type), type);
			}
			else {
				$variable.define(exp, data.name, $variable.kind(data.type), data.type);
			}
			if(data.init) {
				if(data.name.kind === Kind.Identifier) {
					exp.reference(data.name.name);
				}
				exp.code(" = ").compile(data.init, config, Mode.NoIndent | Mode.Assignment);
			}
		}
		else if(__ks_0 === Kind.WhileStatement) {
			node.newControl().code("while(").compile(data.condition, config).code(")").step().compile(data.body, config);
		}
		else {
			console.error(data);
			throw new Error("Unknow kind " + data.kind);
		}
	}
	var $continuous = {
		class(node, data, config, mode, variable) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			var clazz = node.newControl().code("class ").compile(variable.name, config, Mode.Key);
			if(data.extends) {
				variable.extends = node.getVariable(data.extends.name);
				if(variable.extends) {
					clazz.code(" extends ", variable.extends.name.name);
				}
				else {
					throw new Error("Undefined class " + data.extends.name + " at line " + data.extends.start.line);
				}
			}
			clazz.step();
			var ctrl;
			if(!variable.extends) {
				ctrl = clazz.newControl().code("constructor()").step();
				ctrl.newExpression().code("this.__ks_init()");
				ctrl.newExpression().code("this.__ks_cons(arguments)");
			}
			var reflect = {
				inits: 0,
				constructors: [],
				instanceVariables: {},
				classVariables: {},
				instanceMethods: {},
				classMethods: {}
			};
			var noinit = Type.isEmptyObject(variable.instanceVariables);
			if(!noinit) {
				noinit = true;
				var __ks_0 = variable.instanceVariables;
				for(var name in __ks_0) {
					var field = __ks_0[name];
					if(!(noinit)) {
						break;
					}
					if(field.data.defaultValue) {
						noinit = false;
					}
				}
			}
			if(noinit) {
				if(variable.extends) {
					clazz.newControl().code("__ks_init()").step().newExpression().code(variable.extends.name.name, ".prototype.__ks_init.call(this)");
				}
				else {
					clazz.newControl().code("__ks_init()").step();
				}
			}
			else {
				++reflect.inits;
				ctrl = clazz.newControl().code("__ks_init_1()").step();
				$variable.define(ctrl, {
					kind: Kind.Identifier,
					name: "this"
				}, VariableKind.Variable, {
					kind: Kind.TypeReference,
					typeName: variable.name
				});
				var __ks_0 = variable.instanceVariables;
				for(var name in __ks_0) {
					var field = __ks_0[name];
					if(field.data.defaultValue) {
						ctrl.newExpression().code("this." + name + " = ").compile(field.data.defaultValue, config);
					}
				}
				ctrl = clazz.newControl().code("__ks_init()").step();
				if(variable.extends) {
					ctrl.newExpression().code(variable.extends.name.name, ".prototype.__ks_init.call(this)");
				}
				ctrl.newExpression().code(variable.name.name, ".prototype.__ks_init_1.call(this)");
			}
			var __ks_0 = variable.constructors;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, method; __ks_1 < __ks_2; ++__ks_1) {
				method = __ks_0[__ks_1];
				$continuous.constructor(clazz, method.data, config, method.signature, reflect, variable);
			}
			$helper.constructor(clazz, reflect, variable);
			var __ks_1 = variable.instanceMethods;
			for(var name in __ks_1) {
				var methods = __ks_1[name];
				for(var __ks_2 = 0, __ks_3 = methods.length, method; __ks_2 < __ks_3; ++__ks_2) {
					method = methods[__ks_2];
					$continuous.instanceMethod(clazz, method.data, config, method.signature, reflect, name, variable);
				}
				$helper.instanceMethod(clazz, reflect, name, variable);
			}
			var __ks_2 = variable.classMethods;
			for(var name in __ks_2) {
				var methods = __ks_2[name];
				for(var __ks_3 = 0, __ks_4 = methods.length, method; __ks_3 < __ks_4; ++__ks_3) {
					method = methods[__ks_3];
					$continuous.classMethod(clazz, method.data, config, method.signature, reflect, name, variable);
				}
				$helper.classMethod(clazz, reflect, name, variable);
			}
			var __ks_3 = variable.instanceVariables;
			for(var name in __ks_3) {
				var field = __ks_3[name];
				reflect.instanceVariables[name] = field.signature;
			}
			var __ks_4 = variable.classVariables;
			for(var name in __ks_4) {
				var field = __ks_4[name];
				$continuous.classVariable(node, field.data, config, field.signature, reflect, name, variable);
			}
			$helper.reflect(node, variable.name, reflect);
			var references = node.module().listReferences(variable.name.name);
			if(references) {
				for(var __ks_5 = 0, __ks_6 = references.length, ref; __ks_5 < __ks_6; ++__ks_5) {
					ref = references[__ks_5];
					node.newExpression().code(ref);
				}
			}
			variable.constructors = reflect.constructors;
			variable.instanceVariables = reflect.instanceVariables;
			variable.classVariables = reflect.classVariables;
			variable.instanceMethods = reflect.instanceMethods;
			variable.classMethods = reflect.classMethods;
		},
		classMethod(node, data, config, signature, reflect, name, clazz) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(signature === undefined || signature === null) {
				throw new Error("Missing parameter 'signature'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			if(!reflect.classMethods[name]) {
				reflect.classMethods[name] = [];
			}
			var index = reflect.classMethods[name].length;
			reflect.classMethods[name].push(signature);
			node.newFunction().operation(function(node) {
				if(node === undefined || node === null) {
					throw new Error("Missing parameter 'node'");
				}
				node.code("static __ks_sttc_" + name + "_" + index + "(");
				$function.parameters(node, data, config, function(node) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					node.code(")").step();
				});
				$method.fields(node, data.parameters, config, clazz);
				if(data.body.kind === Kind.Block) {
					node.compile(data.body, config);
				}
				else {
					node.newExpression().code("return ").compile(data.body, config);
				}
			});
		},
		classVariable(node, data, config, signature, reflect, name, clazz) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(signature === undefined || signature === null) {
				throw new Error("Missing parameter 'signature'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			reflect.classVariables[name] = signature;
			if(data.defaultValue) {
				node.newExpression().compile(clazz.name, config).code("." + name + " = ").compile(data.defaultValue, config);
			}
		},
		constructor(node, data, config, signature, reflect, clazz) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(signature === undefined || signature === null) {
				throw new Error("Missing parameter 'signature'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			var index = reflect.constructors.length;
			reflect.constructors.push(signature);
			node.newFunction().operation(function(node) {
				if(node === undefined || node === null) {
					throw new Error("Missing parameter 'node'");
				}
				node.code("__ks_cons_" + index + "(");
				$function.parameters(node, data, config, function(node) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					node.code(")").step();
				});
				var variable = $variable.define(node, {
					kind: Kind.Identifier,
					name: "this"
				}, VariableKind.Variable, {
					kind: Kind.TypeReference,
					typeName: clazz.name
				});
				variable.callReplacement = function(node, data, list) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					if(data === undefined || data === null) {
						throw new Error("Missing parameter 'data'");
					}
					if(list === undefined || list === null) {
						throw new Error("Missing parameter 'list'");
					}
					node.code(clazz.name.name, ".prototype.__ks_cons.call(this, [");
					for(var i = 0, __ks_0 = data.arguments.length; i < __ks_0; ++i) {
						if(i) {
							node.code(", ");
						}
						node.compile(data.arguments[i], config);
					}
					node.code("])");
				};
				if(clazz.extends) {
					variable = $variable.define(node, {
						kind: Kind.Identifier,
						name: "super"
					}, VariableKind.Variable);
					variable.callReplacement = function(node, data, list) {
						if(node === undefined || node === null) {
							throw new Error("Missing parameter 'node'");
						}
						if(data === undefined || data === null) {
							throw new Error("Missing parameter 'data'");
						}
						if(list === undefined || list === null) {
							throw new Error("Missing parameter 'list'");
						}
						node.code(clazz.extends.name.name, ".prototype.__ks_cons.call(this, [");
						for(var i = 0, __ks_0 = data.arguments.length; i < __ks_0; ++i) {
							if(i) {
								node.code(", ");
							}
							node.compile(data.arguments[i], config);
						}
						node.code("])");
					};
				}
				$method.fields(node, data.parameters, config, clazz);
				if(data.body) {
					if(data.body.kind === Kind.Block) {
						node.compile(data.body, config);
					}
					else {
						node.newExpression().compile(data.body, config);
					}
				}
			});
		},
		instanceMethod(node, data, config, signature, reflect, name, clazz) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(signature === undefined || signature === null) {
				throw new Error("Missing parameter 'signature'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			if(!reflect.instanceMethods[name]) {
				reflect.instanceMethods[name] = [];
			}
			var index = reflect.instanceMethods[name].length;
			reflect.instanceMethods[name].push(signature);
			node.newFunction().operation(function(node) {
				if(node === undefined || node === null) {
					throw new Error("Missing parameter 'node'");
				}
				node.code("__ks_func_" + name + "_" + index + "(");
				$function.parameters(node, data, config, function(node) {
					if(node === undefined || node === null) {
						throw new Error("Missing parameter 'node'");
					}
					node.code(")").step();
				});
				$variable.define(node, {
					kind: Kind.Identifier,
					name: "this"
				}, VariableKind.Variable, {
					kind: Kind.TypeReference,
					typeName: clazz.name
				});
				if(clazz.extends) {
					var variable = $variable.define(node, {
						kind: Kind.Identifier,
						name: "super"
					}, VariableKind.Variable);
					variable.callReplacement = function(node, data, list) {
						if(node === undefined || node === null) {
							throw new Error("Missing parameter 'node'");
						}
						if(data === undefined || data === null) {
							throw new Error("Missing parameter 'data'");
						}
						if(list === undefined || list === null) {
							throw new Error("Missing parameter 'list'");
						}
						node.code("super." + name + "(");
						for(var i = 0, __ks_0 = data.arguments.length; i < __ks_0; ++i) {
							if(i) {
								node.code(", ");
							}
							node.compile(data.arguments[i], config);
						}
						node.code(")");
					};
				}
				$method.fields(node, data.parameters, config, clazz);
				if(data.body.kind === Kind.Block) {
					node.compile(data.body, config);
				}
				else {
					node.newExpression().code("return ").compile(data.body, config);
				}
			});
		},
		methodCall(variable, fnName, argName, retCode, node, method, index) {
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			if(fnName === undefined || fnName === null) {
				throw new Error("Missing parameter 'fnName'");
			}
			if(argName === undefined || argName === null) {
				throw new Error("Missing parameter 'argName'");
			}
			if(retCode === undefined || retCode === null) {
				throw new Error("Missing parameter 'retCode'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(method === undefined || method === null) {
				throw new Error("Missing parameter 'method'");
			}
			if(index === undefined || index === null) {
				throw new Error("Missing parameter 'index'");
			}
			if(method.max === 0) {
				node.code(retCode, variable.name.name, ".", fnName, index, ".apply(this)");
			}
			else {
				node.code(retCode, variable.name.name, ".", fnName, index, ".apply(this, ", argName, ")");
			}
		}
	};
	var $extern = {
		classMember(data, variable, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var __ks_0 = data.kind;
			if(__ks_0 === Kind.FieldDeclaration) {
				console.error(data);
				throw new Error("Not Implemented");
			}
			else if(__ks_0 === Kind.MethodAliasDeclaration) {
				if(data.name.name === variable.name.name) {
					console.error(data);
					throw new Error("Not Implemented");
				}
				else {
				}
			}
			else if(__ks_0 === Kind.MethodDeclaration) {
				if(data.name.name === variable.name.name) {
					variable.constructors.push($function.signature(data, node));
				}
				else {
					var instance = true;
					for(var i = 0, __ks_1 = data.modifiers.length; instance && i < __ks_1; ++i) {
						if(data.modifiers[i].kind === MemberModifier.Static) {
							instance = false;
						}
					}
					var methods;
					if(instance) {
						methods = variable.instanceMethods[data.name.name] || ((variable.instanceMethods[data.name.name] = []));
					}
					else {
						methods = variable.classMethods[data.name.name] || ((variable.classMethods[data.name.name] = []));
					}
					methods.push($function.signature(data, node));
				}
			}
			else {
				console.error(data);
				throw new Error("Unknow kind " + data.kind);
			}
		}
	};
	var $field = {
		prepare(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			return {
				data: data,
				signature: $field.signature(data, node)
			};
		},
		signature(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var signature = {
				access: MemberAccess.Public
			};
			if(data.modifiers) {
				var __ks_0 = data.modifiers;
				for(var __ks_1 = 0, __ks_2 = __ks_0.length, modifier; __ks_1 < __ks_2; ++__ks_1) {
					modifier = __ks_0[__ks_1];
					if(modifier.kind === MemberModifier.Private) {
						signature.access = MemberAccess.Private;
					}
					else if(modifier.kind === MemberModifier.Protected) {
						signature.access = MemberAccess.Protected;
					}
				}
			}
			var type, __ks_0;
			if(data.type && (Type.isValue(__ks_0 = $signature.type(data.type, node)) ? (type = __ks_0, true) : false)) {
				signature.type = type;
			}
			return signature;
		}
	};
	var $final = {
		callee(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var variable = $variable.fromAST(data, node);
			if(variable) {
				if(Type.isArray(variable)) {
					return {
						variables: variable,
						instance: true
					};
				}
				else if((variable.kind === VariableKind.Class) && variable.final) {
					if(variable.final.classMethods[data.property.name]) {
						return {
							variable: variable,
							instance: false
						};
					}
					else if(variable.final.instanceMethods[data.property.name]) {
						return {
							variable: variable,
							instance: true
						};
					}
				}
			}
			return false;
		},
		class(node, data, config, mode, variable) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			var clazz = node.newControl().code("class ").compile(variable.name, config, Mode.Key);
			if(data.extends) {
				variable.extends = node.getVariable(data.extends.name);
				if(variable.extends) {
					clazz.code(" extends ", variable.extends.name.name);
				}
				else {
					throw new Error("Undefined class " + data.extends.name + " at line " + data.extends.start.line);
				}
			}
			clazz.step();
			var noinit = Type.isEmptyObject(variable.instanceVariables);
			if(!noinit) {
				noinit = true;
				var __ks_0 = variable.instanceVariables;
				for(var name in __ks_0) {
					var field = __ks_0[name];
					if(!(noinit)) {
						break;
					}
					if(field.data.defaultValue) {
						noinit = false;
					}
				}
			}
			var ctrl;
			if(variable.extends) {
				ctrl = clazz.newControl().code("__ks_init()").step();
				ctrl.newExpression().code(variable.extends.name.name, ".prototype.__ks_init.call(this)");
				if(!noinit) {
					$variable.define(ctrl, {
						kind: Kind.Identifier,
						name: "this"
					}, VariableKind.Variable, {
						kind: Kind.TypeReference,
						typeName: variable.name
					});
					var __ks_0 = variable.instanceVariables;
					for(var name in __ks_0) {
						var field = __ks_0[name];
						if(field.data.defaultValue) {
							ctrl.newExpression().code("this." + name + " = ").compile(field.data.defaultValue, config);
						}
					}
				}
			}
			else {
				ctrl = clazz.newControl().code("constructor()").step();
				if(!noinit) {
					$variable.define(ctrl, {
						kind: Kind.Identifier,
						name: "this"
					}, VariableKind.Variable, {
						kind: Kind.TypeReference,
						typeName: variable.name
					});
					var __ks_0 = variable.instanceVariables;
					for(var name in __ks_0) {
						var field = __ks_0[name];
						if(field.data.defaultValue) {
							ctrl.newExpression().code("this." + name + " = ").compile(field.data.defaultValue, config);
						}
					}
				}
				ctrl.newExpression().code("this.__ks_cons(arguments)");
			}
			var reflect = {
				final: true,
				inits: 0,
				constructors: [],
				instanceVariables: {},
				classVariables: {},
				instanceMethods: {},
				classMethods: {}
			};
			var __ks_0 = variable.constructors;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, method; __ks_1 < __ks_2; ++__ks_1) {
				method = __ks_0[__ks_1];
				$continuous.constructor(clazz, method.data, config, method.signature, reflect, variable);
			}
			$helper.constructor(clazz, reflect, variable);
			var __ks_1 = variable.instanceMethods;
			for(var name in __ks_1) {
				var methods = __ks_1[name];
				for(var __ks_2 = 0, __ks_3 = methods.length, method; __ks_2 < __ks_3; ++__ks_2) {
					method = methods[__ks_2];
					$continuous.instanceMethod(clazz, method.data, config, method.signature, reflect, name, variable);
				}
				$helper.instanceMethod(clazz, reflect, name, variable);
			}
			var __ks_2 = variable.classMethods;
			for(var name in __ks_2) {
				var methods = __ks_2[name];
				for(var __ks_3 = 0, __ks_4 = methods.length, method; __ks_3 < __ks_4; ++__ks_3) {
					method = methods[__ks_3];
					$continuous.classMethod(clazz, method.data, config, method.signature, reflect, name, variable);
				}
				$helper.classMethod(clazz, reflect, name, variable);
			}
			var __ks_3 = variable.instanceVariables;
			for(var name in __ks_3) {
				var field = __ks_3[name];
				reflect.instanceVariables[name] = field.signature;
			}
			var __ks_4 = variable.classVariables;
			for(var name in __ks_4) {
				var field = __ks_4[name];
				$continuous.classVariable(node, field.data, config, field.signature, reflect, name, variable);
			}
			$helper.reflect(node, variable.name, reflect);
			var references = node.module().listReferences(variable.name.name);
			if(references) {
				for(var __ks_5 = 0, __ks_6 = references.length, ref; __ks_5 < __ks_6; ++__ks_5) {
					ref = references[__ks_5];
					node.newExpression().code(ref);
				}
			}
			variable.constructors = reflect.constructors;
			variable.instanceVariables = reflect.instanceVariables;
			variable.classVariables = reflect.classVariables;
			variable.instanceMethods = reflect.instanceMethods;
			variable.classMethods = reflect.classMethods;
		}
	};
	var $function = {
		arity(parameter) {
			if(parameter === undefined || parameter === null) {
				throw new Error("Missing parameter 'parameter'");
			}
			for(var i = 0, __ks_0 = parameter.modifiers.length; i < __ks_0; ++i) {
				if(parameter.modifiers[i].kind === ParameterModifier.Rest) {
					return parameter.modifiers[i].arity;
				}
			}
			return null;
		},
		parameters(node, data, config, fn) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(fn === undefined || fn === null) {
				throw new Error("Missing parameter 'fn'");
			}
			if(config.parameters === "es5") {
				$function.parametersES5(node, data, config, fn);
			}
			else if(config.parameters === "es6") {
				$function.parametersES6(node, data, config, fn);
			}
			else {
				$function.parametersKS(node, data, config, fn);
			}
		},
		parametersES5(node, data, config, fn) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(fn === undefined || fn === null) {
				throw new Error("Missing parameter 'fn'");
			}
			var signature = $function.signature(data, node);
			var __ks_0 = data.parameters;
			for(var i = 0, __ks_1 = __ks_0.length, parameter; i < __ks_1; ++i) {
				parameter = __ks_0[i];
				if(signature.parameters[i].rest) {
					throw new Error("Parameter can't be a rest parameter at line " + parameter.start.line);
				}
				else if(parameter.defaultValue) {
					throw new Error("Parameter can't have a default value at line " + parameter.start.line);
				}
				else if(parameter.type && parameter.type.nullable) {
					throw new Error("Parameter can't be nullable at line " + parameter.start.line);
				}
				else if(!parameter.name) {
					throw new Error("Parameter must be named at line " + parameter.start.line);
				}
				if(i) {
					node.code(", ");
				}
				node.parameter(parameter.name, config, parameter.type);
			}
			fn(node);
		},
		parametersES6(node, data, config, fn) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(fn === undefined || fn === null) {
				throw new Error("Missing parameter 'fn'");
			}
			var signature = $function.signature(data, node);
			var rest = false;
			var __ks_0 = data.parameters;
			for(var i = 0, __ks_1 = __ks_0.length, parameter; i < __ks_1; ++i) {
				parameter = __ks_0[i];
				if(!parameter.name) {
					throw new Error("Parameter must be named at line " + parameter.start.line);
				}
				if(i) {
					node.code(", ");
				}
				if(signature.parameters[i].rest) {
					node.code("...");
					rest = true;
					node.parameter(parameter.name, config, {
						kind: Kind.TypeReference,
						typeName: {
							kind: Kind.Identifier,
							name: "Array"
						}
					});
				}
				else if(rest) {
					throw new Error("Parameter must be before the rest parameter at line " + parameter.start.line);
				}
				else {
					node.parameter(parameter.name, config, parameter.type);
				}
				if(parameter.type) {
					if(parameter.type.nullable && !parameter.defaultValue) {
						node.code(" = null");
					}
				}
				if(parameter.defaultValue) {
					node.code(" = ").compile(parameter.defaultValue, config);
				}
			}
			fn(node);
		},
		parametersKS(node, data, config, fn) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(fn === undefined || fn === null) {
				throw new Error("Missing parameter 'fn'");
			}
			var signature = $function.signature(data, node);
			var parameter;
			var ctrl;
			var ctrl2;
			var name;
			var arity;
			var maxb = 0;
			var rb = 0;
			var db = 0;
			var rr = 0;
			var maxa = 0;
			var ra = 0;
			var fr = false;
			var rest = -1;
			var __ks_0 = signature.parameters;
			for(var i = 0, __ks_1 = __ks_0.length; i < __ks_1; ++i) {
				parameter = __ks_0[i];
				if(rest !== -1) {
					if(parameter.min) {
						ra += parameter.min;
					}
					maxa += parameter.max;
					if(parameter.rest) {
						fr = true;
					}
				}
				else if(parameter.max === Infinity) {
					rest = i;
					rr = parameter.min;
				}
				else {
					if(parameter.min === 0) {
						++db;
					}
					else {
						rb += parameter.min;
					}
					maxb += parameter.max;
					if(parameter.rest) {
						fr = true;
					}
				}
			}
			var inc = false;
			var l = (rest !== -1) ? (rest) : (data.parameters.length);
			if(((rest !== -1) && !fr && ((db === 0) || ((db + 1) === rest))) || ((rest === -1) && ((!signature.async && (signature.max === l) && ((db === 0) || (db === l))) || (signature.async && (signature.max === (l + 1)) && ((db === 0) || (db === (l + 1))))))) {
				var names = [];
				for(var i = 0, __ks_1 = l; i < __ks_1; ++i) {
					parameter = data.parameters[i];
					if(i) {
						node.code(", ");
					}
					if(parameter.name) {
						names[i] = parameter.name;
					}
					else {
						names[i] = node.newTempName();
					}
					node.parameter(names[i], config, parameter.type);
					if(parameter.type) {
						if(parameter.type.nullable && !parameter.defaultValue) {
							node.code(" = null");
						}
					}
				}
				if(!ra && (rest !== -1) && ((signature.parameters[rest].type === "Any") || !maxa)) {
					if(rest) {
						node.code(", ");
					}
					if(data.parameters[rest].name) {
						names[rest] = data.parameters[rest].name;
					}
					else {
						names[rest] = node.newTempName();
					}
					node.code("...").parameter(names[rest], config, {
						kind: Kind.TypeReference,
						typeName: {
							kind: Kind.Identifier,
							name: "Array"
						}
					});
				}
				else if(signature.async && !ra) {
					if(l) {
						node.code(", ");
					}
					node.parameter("__ks_cb", config);
				}
				fn(node);
				if(ra) {
					node.newControl().code("if(arguments.length < ", signature.min, ")").step().newExpression().code("throw new Error(\"Wrong number of arguments\")");
				}
				for(var i = 0, __ks_1 = l; i < __ks_1; ++i) {
					parameter = data.parameters[i];
					if(parameter.name && (!parameter.type || !parameter.type.nullable || parameter.defaultValue)) {
						ctrl = node.newControl().code("if(").compile(parameter.name, config).code(" === undefined");
						if(!parameter.type || !parameter.type.nullable) {
							ctrl.code(" || ").compile(parameter.name, config).code(" === null");
						}
						ctrl.code(")").step();
						if(parameter.defaultValue) {
							ctrl.newExpression().compile(parameter.name, config).code(" = ").compile(parameter.defaultValue, config);
						}
						else {
							ctrl.newExpression().code("throw new Error(\"Missing parameter '").compile(parameter.name, config).code("'\")");
						}
					}
					if(!$type.isAny(parameter.type)) {
						ctrl = node.newControl();
						ctrl.code("if(");
						if(parameter.type.nullable) {
							ctrl.compile(names[i], config).code(" !== null && ");
						}
						ctrl.code("!");
						$type.check(ctrl, names[i], parameter.type, config);
						ctrl.code(")").step().newExpression().code("throw new Error(\"Invalid type for parameter '").compile(parameter.name, config).code("'\")");
					}
				}
				if(ra) {
					parameter = data.parameters[rest];
					if(signature.parameters[rest].type === "Any") {
						if(parameter.name) {
							node.newExpression().code($variable.scope(config), "__ks_i");
							node.newExpression().code($variable.scope(config)).parameter(parameter.name, config).code(" = arguments.length > " + (maxb + ra) + " ? Array.prototype.slice.call(arguments, " + maxb + ", __ks_i = arguments.length - " + ra + ") : (__ks_i = " + maxb + ", [])");
						}
						else {
							node.newExpression().code($variable.scope(config), "__ks_i = arguments.length > " + (maxb + ra) + " ? arguments.length - " + ra + " : " + maxb);
						}
					}
					else {
						node.newExpression().code($variable.scope(config), "__ks_i");
						if(parameter.name) {
							node.newExpression().code($variable.scope(config)).parameter(parameter.name, config).code(" = []");
						}
					}
				}
				else if((rest !== -1) && (signature.parameters[rest].type !== "Any") && maxa) {
					parameter = data.parameters[rest];
					if(maxb) {
					}
					else {
						node.newExpression().code($variable.scope(config), "__ks_i = -1");
					}
					if(parameter.name) {
						node.newExpression().code($variable.scope(config)).parameter(parameter.name, config, {
							kind: Kind.TypeReference,
							typeName: {
								kind: Kind.Identifier,
								name: "Array"
							}
						}).code(" = []");
					}
					ctrl = node.newControl().code("while(");
					$type.check(ctrl, "arguments[++__ks_i]", parameter.type, config);
					ctrl.code(")").step();
					if(parameter.name) {
						ctrl.newExpression().parameter(parameter.name, config).code(".push(arguments[__ks_i])");
					}
				}
				if(rest !== -1) {
					parameter = data.parameters[rest];
					if(((arity = $function.arity(parameter))) && arity.min) {
						node.newControl().code("if(").parameter(parameter.name, config).code(".length < ", arity.min, ")").step().newExpression().code("throw new Error(\"Wrong number of arguments\")");
					}
				}
				else if(signature.async && !ra) {
					node.newControl().code("if(!Type.isFunction(__ks_cb))").step().newExpression().code("throw new Error(\"Invalid callback\")");
				}
			}
			else {
				fn(node);
				if(signature.min) {
					node.newControl().code("if(arguments.length < ", signature.min, ")").step().newExpression().code("throw new Error(\"Wrong number of arguments\")");
				}
				node.newExpression().code($variable.scope(config), "__ks_i = -1");
				var required = rb;
				var optional = 0;
				for(var i = 0, __ks_1 = l; i < __ks_1; ++i) {
					parameter = data.parameters[i];
					if(parameter.name) {
						$variable.define(node, parameter.name, $variable.kind(parameter.type), parameter.type);
					}
					if((arity = $function.arity(parameter))) {
						required -= arity.min;
						if(parameter.name) {
							if($type.isAny(parameter.type)) {
								if(required) {
									node.newExpression().code($variable.scope(config)).compile(parameter.name, config).code(" = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - ", required, ", __ks_i + ", arity.max + 1, "))");
									if((i + 1) < data.parameters.length) {
										node.newExpression().code("__ks_i += ").parameter(parameter.name, config).code(".length");
									}
								}
								else {
									node.newExpression().code($variable.scope(config)).compile(parameter.name, config).code(" = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + ", arity.max + 1, "))");
									if((i + 1) < data.parameters.length) {
										node.newExpression().code("__ks_i += ").parameter(parameter.name, config).code(".length");
									}
								}
							}
							else {
								node.newExpression().code($variable.scope(config)).compile(parameter.name, config).code(" = []");
								ctrl = node.newControl();
								if(required) {
									ctrl.code("while(__ks_i < arguments.length - ", required, " && ");
								}
								else {
									ctrl.code("while(__ks_i + 1 < arguments.length && ");
								}
								ctrl.compile(parameter.name, config).code(".length < ", arity.max, " )").step();
							}
						}
						else {
						}
						optional += arity.max - arity.min;
					}
					else {
						if((parameter.type && parameter.type.nullable) || parameter.defaultValue) {
							ctrl = node.newControl().code("if(arguments.length > ", signature.min + optional, ")").step();
							if($type.isAny(parameter.type)) {
								if(parameter.name) {
									ctrl.newExpression().code("var ").compile(parameter.name, config).code(" = arguments[++__ks_i]");
								}
								else {
									ctrl.newExpression().code("++__ks_i");
								}
							}
							else {
								ctrl2 = ctrl.newControl().code("if(");
								$type.check(ctrl2, "arguments[__ks_i + 1]", parameter.type, config);
								ctrl2.code(")").step().newExpression().code("var ").compile(parameter.name, config).code(" = arguments[++__ks_i]");
								ctrl2.step().code("else ").step();
								if(rest === -1) {
									ctrl2.newExpression().code("throw new Error(\"Invalid type for parameter '").compile(parameter.name, config).code("'\")");
								}
								else if(parameter.defaultValue) {
									ctrl2.newExpression().code("var ").compile(parameter.name, config).code(" = ").compile(parameter.defaultValue, config);
								}
								else {
									ctrl2.newExpression().code("var ").compile(parameter.name, config).code(" = null");
								}
							}
							if(parameter.name) {
								ctrl.step().code("else ").step();
								if(parameter.defaultValue) {
									ctrl.newExpression().code("var ").compile(parameter.name, config).code(" = ").compile(parameter.defaultValue, config);
								}
								else {
									ctrl.newExpression().code("var ").compile(parameter.name, config).code(" = null");
								}
							}
							++optional;
						}
						else {
							if($type.isAny(parameter.type)) {
								if(parameter.name) {
									node.newExpression().code("var ").compile(parameter.name, config).code(" = arguments[++__ks_i]");
								}
								else {
									node.newExpression().code("++__ks_i");
								}
							}
							else {
								if(parameter.name) {
									ctrl = node.newControl().code("if(");
									$type.check(ctrl, "arguments[++__ks_i]", parameter.type, config);
									ctrl.code(")").step().newExpression().code("var ").compile(parameter.name, config).code(" = arguments[__ks_i]");
									ctrl.step().code("else ").newExpression().code("throw new Error(\"Invalid type for parameter '").compile(parameter.name, config).code("'\")");
								}
								else {
									ctrl = node.newControl().code("if(!");
									$type.check(ctrl, "arguments[++__ks_i]", parameter.type, config);
									ctrl.code(")").step().newExpression().code("throw new Error(\"Wrong type of arguments\")");
								}
							}
							--required;
						}
					}
				}
				if(rest !== -1) {
					parameter = data.parameters[rest];
					if(ra) {
						if(parameter.name) {
							node.newExpression().code($variable.scope(config)).parameter(parameter.name, config, {
								kind: Kind.TypeReference,
								typeName: {
									kind: Kind.Identifier,
									name: "Array"
								}
							}).code(" = arguments.length > __ks_i + ", ra + 1, " ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - " + ra + ") : []");
							if((l + 1) < data.parameters.length) {
								node.newExpression().code("__ks_i += ").parameter(parameter.name, config).code(".length");
							}
						}
						else if((l + 1) < data.parameters.length) {
							node.newControl().code("if(arguments.length > __ks_i + ", ra + 1, ")").step().newExpression().code("__ks_i = arguments.length - ", ra + 1);
						}
					}
					else {
						if(parameter.name) {
							node.newExpression().code($variable.scope(config)).parameter(parameter.name, config, {
								kind: Kind.TypeReference,
								typeName: {
									kind: Kind.Identifier,
									name: "Array"
								}
							}).code(" = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : []");
							if((l + 1) < data.parameters.length) {
								node.newExpression().code("__ks_i += ").parameter(parameter.name, config).code(".length");
							}
						}
					}
				}
			}
			if(ra || maxa) {
				if((ra !== maxa) && (signature.parameters[rest].type !== "Any")) {
					if(ra) {
						node.newExpression().code($variable.scope(config), "__ks_m = __ks_i + ", ra);
					}
					else {
						node.newExpression().code($variable.scope(config), "__ks_m = __ks_i");
					}
				}
				for(var i = rest + 1, __ks_1 = data.parameters.length; i < __ks_1; ++i) {
					parameter = data.parameters[i];
					if(parameter.name) {
						$variable.define(node, parameter.name, $variable.kind(parameter.type), parameter.type);
					}
					if((arity = $function.arity(parameter))) {
						if(arity.min) {
							if(parameter.name) {
								if($type.isAny(parameter.type)) {
									node.newExpression().code($variable.scope(config)).compile(parameter.name, config).code(" = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + ", arity.min + 1, ")");
									if((i + 1) < data.parameters.length) {
										node.newExpression().code("__ks_i += ").parameter(parameter.name, config).code(".length");
									}
								}
								else {
								}
							}
							else {
							}
						}
						else {
						}
					}
					else if((parameter.type && parameter.type.nullable) || parameter.defaultValue) {
						if(signature.parameters[rest].type === "Any") {
							if(parameter.name) {
								if(parameter.defaultValue) {
									node.newExpression().code("var ").compile(parameter.name, config).code(" = ").compile(parameter.defaultValue, config);
								}
								else {
									node.newExpression().code("var ").compile(parameter.name, config).code(" = null");
								}
							}
						}
						else {
							ctrl = node.newControl().code("if(arguments.length > __ks_m)").step();
							if($type.isAny(parameter.type)) {
								if(parameter.name) {
									ctrl.newExpression().code("var ").compile(parameter.name, config).code(" = arguments[", (inc) ? ("++") : (""), "__ks_i]");
								}
								else {
									ctrl.newExpression().code("++__ks_i");
								}
							}
							else {
								ctrl2 = ctrl.newControl().code("if(");
								$type.check(ctrl2, "arguments[" + (inc ? "++" : "") + "__ks_i]", parameter.type, config);
								ctrl2.code(")").step().newExpression().code("var ").compile(parameter.name, config).code(" = arguments[__ks_i]");
								ctrl2.step().code("else ");
								if(parameter.defaultValue) {
									ctrl2.newExpression().code("var ").compile(parameter.name, config).code(" = ").compile(parameter.defaultValue, config);
								}
								else {
									ctrl2.newExpression().code("var ").compile(parameter.name, config).code(" = null");
								}
							}
							if(parameter.name) {
								ctrl.step().code("else ").step();
								if(parameter.defaultValue) {
									ctrl.newExpression().code("var ").compile(parameter.name, config).code(" = ").compile(parameter.defaultValue, config);
								}
								else {
									ctrl.newExpression().code("var ").compile(parameter.name, config).code(" = null");
								}
							}
							if(!inc) {
								inc = true;
							}
						}
					}
					else {
						if($type.isAny(parameter.type)) {
							if(parameter.name) {
								node.newExpression().code("var ").compile(parameter.name, config).code(" = arguments[", (inc) ? ("++") : (""), "__ks_i]");
							}
							else {
								node.newExpression().code((inc) ? ("++") : (""), "__ks_i");
							}
						}
						else {
							if(parameter.name) {
								ctrl = node.newControl().code("if(");
								$type.check(ctrl, "arguments[" + (inc ? "++" : "") + "__ks_i]", parameter.type, config);
								ctrl.code(")").step().newExpression().code("var ").compile(parameter.name, config).code(" = arguments[__ks_i]");
								ctrl.step().code("else ").newExpression().code("throw new Error(\"Invalid type for parameter '").compile(parameter.name, config).code("'\")");
							}
							else {
								ctrl = node.newControl().code("if(!");
								$type.check(ctrl, "arguments[" + (inc ? "++" : "") + "__ks_i]", parameter.type, config);
								ctrl.code(")").step().newExpression().code("throw new Error(\"Wrong type of arguments\")");
							}
						}
						if(!inc) {
							inc = true;
						}
					}
				}
			}
		},
		signature(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var signature = {
				min: 0,
				max: 0,
				parameters: []
			};
			if(data.modifiers) {
				var __ks_0 = data.modifiers;
				for(var __ks_1 = 0, __ks_2 = __ks_0.length, modifier; __ks_1 < __ks_2; ++__ks_1) {
					modifier = __ks_0[__ks_1];
					if(modifier.kind === FunctionModifier.Async) {
						signature.async = true;
					}
				}
			}
			var __ks_0 = data.parameters;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, parameter; __ks_1 < __ks_2; ++__ks_1) {
				parameter = __ks_0[__ks_1];
				signature.parameters.push(parameter = $function.signatureParameter(parameter, node));
				if(parameter.max === Infinity) {
					if(signature.max === Infinity) {
						throw new Error("Function can have only one rest parameter");
					}
					else {
						signature.max = Infinity;
					}
				}
				else {
					signature.max += parameter.max;
				}
				signature.min += parameter.min;
			}
			if(signature.async) {
				signature.parameters.push({
					type: "Function",
					min: 1,
					max: 1
				});
				++signature.min;
				++signature.max;
			}
			return signature;
		},
		signatureParameter(parameter, node) {
			if(parameter === undefined || parameter === null) {
				throw new Error("Missing parameter 'parameter'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var signature = {
				type: $signature.type(parameter.type, node),
				min: (parameter.defaultValue || (parameter.type && parameter.type.nullable)) ? (0) : (1),
				max: 1
			};
			if(parameter.modifiers) {
				var __ks_0 = parameter.modifiers;
				for(var __ks_1 = 0, __ks_2 = __ks_0.length, modifier; __ks_1 < __ks_2; ++__ks_1) {
					modifier = __ks_0[__ks_1];
					if(modifier.kind === ParameterModifier.Rest) {
						signature.rest = true;
						if(modifier.arity) {
							signature.min = modifier.arity.min;
							signature.max = modifier.arity.max;
						}
						else {
							signature.min = 0;
							signature.max = Infinity;
						}
					}
				}
			}
			return signature;
		}
	};
	var $helper = {
		classMethod(clazz, reflect, name, variable) {
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			var extend = false;
			if(variable.extends) {
				extend = function() {
					if(arguments.length < 1) {
						throw new Error("Wrong number of arguments");
					}
					var __ks_i = -1;
					var node = arguments[++__ks_i];
					if(arguments.length > 1) {
						var ctrl = arguments[++__ks_i];
					}
					else  {
						var ctrl = null;
					}
					if(variable.extends.instanceMethods[name]) {
						node.code("return " + variable.extends.name.name + "." + name + ".apply(null, arguments)");
					}
					else {
						ctrl.step().code("else if(" + variable.extends.name.name + "." + name + ")").step().code("return " + variable.extends.name.name + "." + name + ".apply(null, arguments)");
						node.code("throw new Error(\"Wrong number of arguments\")");
					}
				};
			}
			$helper.methods(extend, clazz.newControl(), "static " + name + "()", reflect.classMethods[name], __ks_Function._cm_vcurry($continuous.methodCall, null, variable, "__ks_sttc_" + name + "_", "arguments", "return "), "arguments", "classMethods." + name, true);
		},
		constructor(clazz, reflect, variable) {
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			var extend = false;
			if(variable.extends) {
				extend = function() {
					if(arguments.length < 1) {
						throw new Error("Wrong number of arguments");
					}
					var __ks_i = -1;
					var node = arguments[++__ks_i];
					if(arguments.length > 1) {
						var ctrl = arguments[++__ks_i];
					}
					else  {
						var ctrl = null;
					}
					if(ctrl) {
						ctrl.step().code("else").step().code(variable.extends.name.name + ".prototype.__ks_cons.call(this, args)");
					}
					else {
						node.code(variable.extends.name.name + ".prototype.__ks_cons.call(this, args)");
					}
				};
			}
			$helper.methods(extend, clazz.newControl(), "__ks_cons(args)", reflect.constructors, __ks_Function._cm_vcurry($continuous.methodCall, null, variable, "prototype.__ks_cons_", "args", ""), "args", "constructors", false);
		},
		decide(node, type, index, path, argName) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(type === undefined || type === null) {
				throw new Error("Missing parameter 'type'");
			}
			if(index === undefined || index === null) {
				throw new Error("Missing parameter 'index'");
			}
			if(path === undefined || path === null) {
				throw new Error("Missing parameter 'path'");
			}
			if(argName === undefined || argName === null) {
				throw new Error("Missing parameter 'argName'");
			}
			if($typeofs[type]) {
				node.code($typeofs[type] + "(" + argName + "[" + index + "])");
			}
			else {
				node.code("Type.is(" + argName + "[" + index + "], " + path + ")");
			}
		},
		instanceMethod(clazz, reflect, name, variable) {
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			var extend = false;
			if(variable.extends) {
				extend = function() {
					if(arguments.length < 1) {
						throw new Error("Wrong number of arguments");
					}
					var __ks_i = -1;
					var node = arguments[++__ks_i];
					if(arguments.length > 1) {
						var ctrl = arguments[++__ks_i];
					}
					else  {
						var ctrl = null;
					}
					if(variable.extends.instanceMethods[name]) {
						node.code("return " + variable.extends.name.name + ".prototype." + name + ".apply(this, arguments)");
					}
					else {
						ctrl.step().code("else if(" + variable.extends.name.name + ".prototype." + name + ")").step().code("return " + variable.extends.name.name + ".prototype." + name + ".apply(this, arguments)");
						node.code("throw new Error(\"Wrong number of arguments\")");
					}
				};
			}
			$helper.methods(extend, clazz.newControl(), name + "()", reflect.instanceMethods[name], __ks_Function._cm_vcurry($continuous.methodCall, null, variable, "prototype.__ks_func_" + name + "_", "arguments", "return "), "arguments", "instanceMethods." + name, true);
		},
		methods(extend, node, header, methods, call, argName, refName, returns) {
			if(extend === undefined || extend === null) {
				throw new Error("Missing parameter 'extend'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(header === undefined || header === null) {
				throw new Error("Missing parameter 'header'");
			}
			if(methods === undefined || methods === null) {
				throw new Error("Missing parameter 'methods'");
			}
			if(call === undefined || call === null) {
				throw new Error("Missing parameter 'call'");
			}
			if(argName === undefined || argName === null) {
				throw new Error("Missing parameter 'argName'");
			}
			if(refName === undefined || refName === null) {
				throw new Error("Missing parameter 'refName'");
			}
			if(returns === undefined || returns === null) {
				throw new Error("Missing parameter 'returns'");
			}
			node.code(header).step();
			var method;
			if(methods.length === 0) {
				if(extend) {
					extend(node);
				}
				else {
					node.newControl().code("if(" + argName + ".length !== 0)").step().code("throw new Error(\"Wrong number of arguments\")");
				}
			}
			else if(methods.length === 1) {
				method = methods[0];
				if((method.min === 0) && (method.max >= Infinity)) {
					call(node, method, 0);
				}
				else {
					if(method.min === method.max) {
						var ctrl = node.newControl();
						ctrl.code("if(" + argName + ".length === " + method.min + ")").step();
						call(ctrl, method, 0);
						if(returns) {
							if(extend) {
								extend(node, ctrl);
							}
							else {
								node.code("throw new Error(\"Wrong number of arguments\")");
							}
						}
						else {
							if(extend) {
								extend(node, ctrl);
							}
							else {
								ctrl.step().code("else").step().code("throw new Error(\"Wrong number of arguments\")");
							}
						}
					}
					else if(method.max < Infinity) {
						var ctrl = node.newControl();
						ctrl.code("if(" + argName + ".length >= " + method.min + " && " + argName + ".length <= " + method.max + ")").step();
						call(ctrl, method, 0);
						if(returns) {
							node.code("throw new Error(\"Wrong number of arguments\")");
						}
						else {
							ctrl.step().code("else").step().code("throw new Error(\"Wrong number of arguments\")");
						}
					}
					else {
						call(node, method, 0);
					}
				}
			}
			else {
				var groups = [];
				var nf;
				var group;
				for(var index = 0, __ks_0 = methods.length; index < __ks_0; ++index) {
					method = methods[index];
					method.index = index;
					nf = true;
					for(var __ks_1 = 0, __ks_2 = groups.length; nf && __ks_1 < __ks_2; ++__ks_1) {
						group = groups[__ks_1];
						if(((method.min <= group.min) && (method.max >= group.min)) || ((method.min >= group.min) && (method.max <= group.max)) || ((method.min <= group.max) && (method.max >= group.max))) {
							nf = false;
						}
					}
					if(nf) {
						groups.push({
							min: method.min,
							max: method.max,
							methods: [method]
						});
					}
					else {
						group.min = Math.min(group.min, method.min);
						group.max = Math.max(group.max, method.max);
						group.methods.push(method);
					}
				}
				var ctrl = node.newControl();
				nf = true;
				for(var __ks_0 = 0, __ks_1 = groups.length; __ks_0 < __ks_1; ++__ks_0) {
					group = groups[__ks_0];
					if(group.min === group.max) {
						if(ctrl.length() > 1) {
							ctrl.code("else ");
						}
						ctrl.code("if(" + argName + ".length === " + group.min + ")").step();
						if(group.methods.length === 1) {
							call(ctrl, group.methods[0], group.methods[0].index);
						}
						else {
							$helper.methodCheck(ctrl, group, call, argName, refName, returns);
						}
						ctrl.step();
					}
					else if(group.max < Infinity) {
						if(ctrl.length() > 1) {
							ctrl.code("else ");
						}
						ctrl.code("if(" + argName + ".length >= " + group.min + " && arguments.length <= " + group.max + ")").step();
						if(group.methods.length === 1) {
							call(ctrl, group.methods[0], group.methods[0].index);
						}
						else {
							$helper.methodCheck(ctrl, group, call, argName, refName, returns);
						}
						ctrl.step();
					}
					else {
						nf = false;
						if(ctrl.length() > 1) {
							ctrl.code("else");
						}
						ctrl.step();
						if(group.methods.length === 1) {
							call(ctrl, group.methods[0], group.methods[0].index);
						}
						else {
							$helper.methodCheck(ctrl, group, call, argName, refName, returns);
						}
						ctrl.step();
					}
				}
				if(nf) {
					if(returns) {
						node.code("throw new Error(\"Wrong number of arguments\")");
					}
					else {
						ctrl.code("else").step().code("throw new Error(\"Wrong number of arguments\")");
					}
				}
			}
		},
		methodCheck(node, group, call, argName, refName, returns) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(group === undefined || group === null) {
				throw new Error("Missing parameter 'group'");
			}
			if(call === undefined || call === null) {
				throw new Error("Missing parameter 'call'");
			}
			if(argName === undefined || argName === null) {
				throw new Error("Missing parameter 'argName'");
			}
			if(refName === undefined || refName === null) {
				throw new Error("Missing parameter 'refName'");
			}
			if(returns === undefined || returns === null) {
				throw new Error("Missing parameter 'returns'");
			}
			if($helper.methodCheckTree(group.methods, 0, node, call, argName, refName, returns)) {
				if(returns) {
					node.newExpression().code("throw new Error(\"Wrong type of arguments\")");
				}
				else {
					node.code("else").step().code("throw new Error(\"Wrong type of arguments\")");
				}
			}
		},
		methodCheckTree(methods, index, node, call, argName, refName, returns) {
			if(methods === undefined || methods === null) {
				throw new Error("Missing parameter 'methods'");
			}
			if(index === undefined || index === null) {
				throw new Error("Missing parameter 'index'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(call === undefined || call === null) {
				throw new Error("Missing parameter 'call'");
			}
			if(argName === undefined || argName === null) {
				throw new Error("Missing parameter 'argName'");
			}
			if(refName === undefined || refName === null) {
				throw new Error("Missing parameter 'refName'");
			}
			if(returns === undefined || returns === null) {
				throw new Error("Missing parameter 'returns'");
			}
			var tree = [];
			var usages = [];
			var types;
			var usage;
			var type;
			var nf;
			var t;
			var item;
			for(var i = 0, __ks_0 = methods.length; i < __ks_0; ++i) {
				types = $helper.methodTypes(methods[i], index);
				usage = {
					method: methods[i],
					usage: 0,
					tree: []
				};
				for(var __ks_1 = 0, __ks_2 = types.length; __ks_1 < __ks_2; ++__ks_1) {
					type = types[__ks_1];
					nf = true;
					for(var __ks_3 = 0, __ks_4 = tree.length, tt; nf && __ks_3 < __ks_4; ++__ks_3) {
						tt = tree[__ks_3];
						if($method.sameType(type.type, tt.type)) {
							tt.methods.push(methods[i]);
							nf = false;
						}
					}
					if(nf) {
						item = {
							type: type.type,
							path: "this.constructor.__ks_reflect." + refName + "[" + methods[i].index + "].parameters[" + type.index + "]" + type.path,
							methods: [methods[i]]
						};
						tree.push(item);
						usage.tree.push(item);
						++usage.usage;
					}
				}
				usages.push(usage);
			}
			if(tree.length === 1) {
				var __ks_item_1 = tree[0];
				if(__ks_item_1.methods.length === 1) {
					call(node, __ks_item_1.methods[0], __ks_item_1.methods[0].index);
					return false;
				}
				else {
					return $helper.methodCheckTree(__ks_item_1.methods, index + 1, node, call, argName, refName, returns);
				}
			}
			else {
				var ctrl = node.newControl();
				var ne = true;
				usages.sort(function(a, b) {
					if(a === undefined || a === null) {
						throw new Error("Missing parameter 'a'");
					}
					if(b === undefined || b === null) {
						throw new Error("Missing parameter 'b'");
					}
					return a.usage - b.usage;
				});
				for(var u = 0, __ks_0 = usages.length; u < __ks_0; ++u) {
					usage = usages[u];
					if(usage.tree.length === usage.usage) {
						item = usage.tree[0];
						if((u + 1) === usages.length) {
							if(ctrl.length() > 1) {
								ctrl.code("else");
								ne = false;
							}
						}
						else {
							if(ctrl.length() > 1) {
								ctrl.code("else ");
							}
							ctrl.code("if(");
							$helper.decide(ctrl, item.type, index, item.path, argName);
							ctrl.code(")");
						}
						ctrl.step();
						if(item.methods.length === 1) {
							call(ctrl, item.methods[0], item.methods[0].index);
						}
						else {
							$helper.methodCheckTree(item.methods, index + 1, ctrl, call, argName, refName, returns);
						}
						ctrl.step();
					}
					else {
						throw new Error("Not Implemented");
					}
				}
				return ne;
			}
		},
		methodTypes(method, index) {
			if(method === undefined || method === null) {
				throw new Error("Missing parameter 'method'");
			}
			if(index === undefined || index === null) {
				throw new Error("Missing parameter 'index'");
			}
			var types = [];
			var k = -1;
			var parameter;
			var __ks_0 = method.parameters;
			for(var i = 0, __ks_1 = __ks_0.length; i < __ks_1; ++i) {
				parameter = __ks_0[i];
				if(k < index) {
					if((k + parameter.max) >= index) {
						if(Type.isArray(parameter.type)) {
							for(var j = 0, __ks_2 = parameter.type.length; j < __ks_2; ++j) {
								types.push({
									type: parameter.type[j],
									index: i,
									path: ".type[" + j + "]"
								});
							}
						}
						else {
							types.push({
								type: parameter.type,
								index: i,
								path: ".type"
							});
						}
					}
					k += parameter.min;
				}
			}
			return types;
		},
		reflect(node, name, reflect) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(reflect === undefined || reflect === null) {
				throw new Error("Missing parameter 'reflect'");
			}
			var classname = name.name;
			var exp = node.newExpression();
			exp.code(classname + ".__ks_reflect = {").indent();
			if(reflect.final) {
				exp.newline().code("final: true,");
			}
			exp.newline().code("inits: " + reflect.inits + ",");
			exp.newline().code("constructors: [").indent();
			for(var i = 0, __ks_0 = reflect.constructors.length; i < __ks_0; ++i) {
				if(i) {
					exp.code(",");
				}
				$helper.reflectMethod(exp, reflect.constructors[i], 0, classname + ".__ks_reflect.constructors[" + i + "].type");
			}
			exp.unindent().newline().code("],");
			exp.newline().code("instanceVariables: {").indent();
			var nf = false;
			var __ks_0 = reflect.instanceVariables;
			for(name in __ks_0) {
				variable = __ks_0[name];
				if(nf) {
					exp.code(",");
				}
				else {
					nf = true;
				}
				$helper.reflectVariable(exp, name, variable, 0, classname + ".__ks_reflect.instanceVariables." + name);
			}
			exp.unindent().newline().code("},");
			exp.newline().code("classVariables: {").indent();
			nf = false;
			var __ks_1 = reflect.classVariables;
			for(name in __ks_1) {
				variable = __ks_1[name];
				if(nf) {
					exp.code(",");
				}
				else {
					nf = true;
				}
				$helper.reflectVariable(exp, name, variable, 0, classname + ".__ks_reflect.classVariables." + name);
			}
			exp.unindent().newline().code("},");
			exp.newline().code("instanceMethods: {").indent();
			nf = false;
			var __ks_2 = reflect.instanceMethods;
			for(name in __ks_2) {
				methods = __ks_2[name];
				if(nf) {
					exp.code(",");
				}
				else {
					nf = true;
				}
				exp.newline().code(name + ": [").indent();
				for(var i = 0, __ks_3 = methods.length; i < __ks_3; ++i) {
					if(i) {
						exp.code(",");
					}
					$helper.reflectMethod(exp, methods[i], 0, classname + ".__ks_reflect.instanceMethods." + name + "[" + i + "]");
				}
				exp.unindent().newline().code("]");
			}
			exp.unindent().newline().code("},");
			exp.newline().code("classMethods: {").indent();
			nf = false;
			var __ks_3 = reflect.classMethods;
			for(name in __ks_3) {
				methods = __ks_3[name];
				if(nf) {
					exp.code(",");
				}
				else {
					nf = true;
				}
				exp.newline().code(name + ": [").indent();
				for(var i = 0, __ks_4 = methods.length; i < __ks_4; ++i) {
					if(i) {
						exp.code(",");
					}
					$helper.reflectMethod(exp, methods[i], 0, classname + ".__ks_reflect.classMethods." + name + "[" + i + "]");
				}
				exp.unindent().newline().code("]");
			}
			exp.unindent().newline().code("}");
			exp.unindent().newline().code("}");
		},
		reflectMethod() {
			if(arguments.length < 3) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var node = arguments[++__ks_i];
			var method = arguments[++__ks_i];
			var mode = arguments[++__ks_i];
			if(arguments.length > 3) {
				var path = arguments[++__ks_i];
			}
			else  {
				var path = null;
			}
			if(!(mode & Mode.NoLine)) {
				node.newline();
			}
			node.code("{").indent();
			node.newline().code("access: " + method.access + ",");
			node.newline().code("min: " + method.min + ",");
			node.newline().code("max: " + (method.max === Infinity ? "Infinity" : method.max) + ",");
			node.newline().code("parameters: [").indent();
			for(var i = 0, __ks_0 = method.parameters.length; i < __ks_0; ++i) {
				if(i) {
					node.code(",");
				}
				$helper.reflectParameter(node, method.parameters[i], path + ".parameters[" + i + "]");
			}
			node.unindent().newline().code("]");
			node.unindent().newline().code("}");
		},
		reflectParameter() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var node = arguments[++__ks_i];
			var parameter = arguments[++__ks_i];
			if(arguments.length > 2) {
				var path = arguments[++__ks_i];
			}
			else  {
				var path = null;
			}
			node.newline().code("{").indent();
			node.newline().code("type: " + $helper.type(parameter.type, node, path));
			node.code(",").newline().code("min: ", parameter.min);
			node.code(",").newline().code("max: ", parameter.max);
			node.unindent().newline().code("}");
		},
		reflectVariable() {
			if(arguments.length < 4) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var node = arguments[++__ks_i];
			var name = arguments[++__ks_i];
			var variable = arguments[++__ks_i];
			var mode = arguments[++__ks_i];
			if(arguments.length > 4) {
				var path = arguments[++__ks_i];
			}
			else  {
				var path = null;
			}
			if(!(mode & Mode.NoLine)) {
				node.newline();
			}
			node.code(name, ": {").indent();
			node.newline().code("access: " + variable.access);
			if(variable.type) {
				node.code(",").newline().code("type: " + $helper.type(variable.type, node, path));
			}
			node.unindent().newline().code("}");
		},
		type() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var type = arguments[++__ks_i];
			var node = arguments[++__ks_i];
			if(arguments.length > 2) {
				var path = arguments[++__ks_i];
			}
			else  {
				var path = null;
			}
			if(Type.isArray(type)) {
				var src = "";
				for(var i = 0, __ks_0 = type.length; i < __ks_0; ++i) {
					if(i) {
						src += ",";
					}
					src += $helper.type(type[i], node, path);
				}
				return "[" + src + "]";
			}
			else if((type === "Any") || (type === "...")) {
				return $quote(type);
			}
			else if($typeofs[type]) {
				return $quote(type);
			}
			else {
				var variable, __ks_0;
				if(Type.isValue(__ks_0 = $variable.fromReflectType(type, node)) ? (variable = __ks_0, true) : false) {
					return type;
				}
				else {
					node.module().addReference(type, path + ".type = " + type);
					return $quote("#" + type);
				}
			}
		}
	};
	function $implement(node, data, config, variable) {
		if(node === undefined || node === null) {
			throw new Error("Missing parameter 'node'");
		}
		if(data === undefined || data === null) {
			throw new Error("Missing parameter 'data'");
		}
		if(config === undefined || config === null) {
			throw new Error("Missing parameter 'config'");
		}
		if(variable === undefined || variable === null) {
			throw new Error("Missing parameter 'variable'");
		}
		var __ks_0 = data.kind;
		if(__ks_0 === Kind.FieldDeclaration) {
			if(variable.final) {
				throw new Error("Can't add a field to a final class");
			}
			else {
				var type = $signature.type(data.type, node);
				node.newExpression().code("Class.newField(" + $quote(data.name.name) + ", " + $helper.type(type, node) + ")");
			}
		}
		else if(__ks_0 === Kind.MethodAliasDeclaration) {
			if(data.name.name === variable.name.name) {
				console.error(data);
				throw new Error("Not Implemented");
			}
			else {
				var instance = true;
				for(var i = 0, __ks_1 = data.modifiers.length; instance && i < __ks_1; ++i) {
					if(data.modifiers[i].kind === MemberModifier.Static) {
						instance = false;
					}
				}
				if(variable.final) {
					if(instance) {
						if(!variable.final.instanceMethods[data.name.name]) {
							variable.final.instanceMethods[data.name.name] = true;
						}
					}
					else {
						if(!variable.final.classMethods[data.name.name]) {
							variable.final.classMethods[data.name.name] = true;
						}
					}
				}
				var exp = node.newExpression().code("Class.", (instance) ? ("newInstanceMethod") : ("newClassMethod"), "({").indent();
				exp.newline().code("class: ").compile(variable.name, config).code(",");
				if(data.name.kind === Kind.Identifier) {
					exp.newline().code("name: ", $quote(data.name.name), ",");
				}
				else if(data.name.kind === Kind.TemplateExpression) {
					exp.newline().code("name: ").compile(data.name, config).code(",");
				}
				else {
					console.error(data.name);
					throw new Error("Not Implemented");
				}
				if(variable.final) {
					exp.newline().code("final: ", variable.final.name, ",");
				}
				exp.newline().code("method: ", $quote(data.alias.name));
				if(data.arguments) {
					exp.code(",").newline().code("arguments: [");
					for(var i = 0, __ks_1 = data.arguments.length; i < __ks_1; ++i) {
						if(i) {
							exp.code(", ");
						}
						exp.compile(data.arguments[i], config);
					}
					exp.code("]");
				}
				exp.code(",").newline().code("signature: ");
				$helper.reflectMethod(exp, $method.signature(data, node), Mode.NoLine);
				exp.unindent().newline().code("})");
				if(data.name.kind === Kind.Identifier) {
					var methods;
					if(instance) {
						variable.instanceMethods[data.name.name] = variable.instanceMethods[data.alias.name];
					}
					else {
						variable.classMethods[data.name.name] = variable.classMethods[data.alias.name];
					}
				}
			}
		}
		else if(__ks_0 === Kind.MethodDeclaration) {
			if(data.name.name === variable.name.name) {
				console.error(data);
				throw new Error("Not Implemented");
			}
			else {
				var instance = true;
				for(var i = 0, __ks_1 = data.modifiers.length; instance && i < __ks_1; ++i) {
					if(data.modifiers[i].kind === MemberModifier.Static) {
						instance = false;
					}
				}
				if(variable.final) {
					if(instance) {
						if(!variable.final.instanceMethods[data.name.name]) {
							variable.final.instanceMethods[data.name.name] = true;
						}
					}
					else {
						if(!variable.final.classMethods[data.name.name]) {
							variable.final.classMethods[data.name.name] = true;
						}
					}
				}
				node.newExpression(Mode.NoIndent).newFunction().operation(function(ctrl) {
					if(ctrl === undefined || ctrl === null) {
						throw new Error("Missing parameter 'ctrl'");
					}
					ctrl.code("Class.", (instance) ? ("newInstanceMethod") : ("newClassMethod"), "({").indent();
					ctrl.newline().code("class: ").compile(variable.name, config).code(",");
					if(data.name.kind === Kind.Identifier) {
						ctrl.newline().code("name: ", $quote(data.name.name), ",");
					}
					else if(data.name.kind === Kind.TemplateExpression) {
						ctrl.newline().code("name: ").compile(data.name, config).code(",");
					}
					else {
						console.error(data.name);
						throw new Error("Not Implemented");
					}
					if(variable.final) {
						ctrl.newline().code("final: ", variable.final.name, ",");
					}
					ctrl.newline().code("function: function(");
					$function.parameters(ctrl, data, config, function(node) {
						if(node === undefined || node === null) {
							throw new Error("Missing parameter 'node'");
						}
						node.code(")").step();
					});
					$variable.define(ctrl, {
						kind: Kind.Identifier,
						name: "this"
					}, VariableKind.Variable, $type.reference(variable.name));
					if(data.body.kind === Kind.Block) {
						ctrl.compile(data.body, config);
					}
					else {
						ctrl.newExpression().code("return ").compile(data.body, config);
					}
					ctrl.step(Mode.NoLine).code(",");
					ctrl.newline().code("signature: ");
					$helper.reflectMethod(ctrl, $method.signature(data, node), Mode.NoLine);
					ctrl.unindent().newline().code("})");
				});
				if(data.name.kind === Kind.Identifier) {
					var methods;
					if(instance) {
						if(!variable.instanceMethods[data.name.name]) {
							variable.instanceMethods[data.name.name] = [];
						}
						methods = variable.instanceMethods[data.name.name];
					}
					else {
						if(!variable.classMethods[data.name.name]) {
							variable.classMethods[data.name.name] = [];
						}
						methods = variable.classMethods[data.name.name];
					}
					var method = {
						kind: Kind.MethodDeclaration,
						name: data.name.name,
						signature: $method.signature(data, node)
					};
					if(data.type) {
						method.type = $type.type(data.type, node);
					}
					methods.push(method);
				}
			}
		}
		else if(__ks_0 === Kind.MethodLinkDeclaration) {
			if(data.name.name === variable.name.name) {
				console.error(data);
				throw new Error("Not Implemented");
			}
			else {
				var instance = true;
				for(var i = 0, __ks_1 = data.modifiers.length; instance && i < __ks_1; ++i) {
					if(data.modifiers[i].kind === MemberModifier.Static) {
						instance = false;
					}
				}
				var exp = node.newExpression().code("Class.", (instance) ? ("newInstanceMethod") : ("newClassMethod"), "({").indent();
				exp.newline().code("class: ").compile(variable.name, config).code(",");
				if(data.name.kind === Kind.Identifier) {
					exp.newline().code("name: ", $quote(data.name.name), ",");
				}
				else if(data.name.kind === Kind.TemplateExpression) {
					exp.newline().code("name: ").compile(data.name, config).code(",");
				}
				else {
					console.error(data.name);
					throw new Error("Not Implemented");
				}
				if(variable.final) {
					exp.newline().code("final: ", variable.final.name, ",");
				}
				exp.newline().code("function: ", data.alias.name);
				if(data.arguments) {
					exp.code(",").newline().code("arguments: [");
					for(var i = 0, __ks_1 = data.arguments.length; i < __ks_1; ++i) {
						if(i) {
							exp.code(", ");
						}
						exp.compile(data.arguments[i], config);
					}
					exp.code("]");
				}
				exp.code(",").newline().code("signature: ");
				$helper.reflectMethod(exp, $method.signature(data, node), Mode.NoLine);
				exp.unindent().newline().code("})");
				if(data.name.kind === Kind.Identifier) {
					var methods;
					if(instance) {
						if(!variable.instanceMethods[data.name.name]) {
							variable.instanceMethods[data.name.name] = [];
						}
						methods = variable.instanceMethods[data.name.name];
					}
					else {
						if(!variable.classMethods[data.name.name]) {
							variable.classMethods[data.name.name] = [];
						}
						methods = variable.classMethods[data.name.name];
					}
					var method = {
						kind: Kind.MethodDeclaration,
						name: data.name.name,
						signature: $method.signature(data, node)
					};
					if(data.type) {
						method.type = $type.type(data.type, node);
					}
					methods.push(method);
				}
			}
		}
		else {
			console.error(data);
			throw new Error("Unknow kind " + data.kind);
		}
	}
	var $import = {
		addVariable(module, node, name, variable) {
			if(module === undefined || module === null) {
				throw new Error("Missing parameter 'module'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			node.addVariable(name, variable);
			module.import(name);
		},
		define() {
			if(arguments.length < 4) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var module = arguments[++__ks_i];
			var node = arguments[++__ks_i];
			var name = arguments[++__ks_i];
			var kind = arguments[++__ks_i];
			if(arguments.length > 4) {
				var type = arguments[++__ks_i];
			}
			else  {
				var type = null;
			}
			$variable.define(node, name, kind, type);
			module.import(name.name || name);
		},
		loadCoreModule(x, module, data, node) {
			if(x === undefined || x === null) {
				throw new Error("Missing parameter 'x'");
			}
			if(module === undefined || module === null) {
				throw new Error("Missing parameter 'module'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if($nodeModules[x]) {
				return $import.loadNodeFile(null, x, module, data, node);
			}
			return false;
		},
		loadDirectory() {
			if(arguments.length < 4) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var x = arguments[++__ks_i];
			if(arguments.length > 4) {
				var moduleName = arguments[++__ks_i];
			}
			else  {
				var moduleName = null;
			}
			var module = arguments[++__ks_i];
			var data = arguments[++__ks_i];
			var node = arguments[++__ks_i];
			var pkgfile = path.join(x, "package.json");
			if(fs.isFile(pkgfile)) {
				try {
					var pkg = JSON.parse(fs.readFile(pkgfile));
					if(pkg.kaoscript && $import.loadKSFile(path.join(x, pkg.kaoscript.main), moduleName, module, data, node)) {
						return true;
					}
					else if(pkg.main && ($import.loadFile(path.join(x, pkg.main), moduleName, module, data, node) || $import.loadDirectory(path.join(x, pkg.main), moduleName, module, data, node))) {
						return true;
					}
				}
				catch(__ks_0) {
				}
			}
			return $import.loadFile(path.join(x, "index"), moduleName, module, data, node);
		},
		loadFile() {
			if(arguments.length < 4) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var x = arguments[++__ks_i];
			if(arguments.length > 4) {
				var moduleName = arguments[++__ks_i];
			}
			else  {
				var moduleName = null;
			}
			var module = arguments[++__ks_i];
			var data = arguments[++__ks_i];
			var node = arguments[++__ks_i];
			if(fs.isFile(x)) {
				if(x.endsWith($extensions.source)) {
					return $import.loadKSFile(x, moduleName, module, data, node);
				}
				else {
					return $import.loadNodeFile(x, moduleName, module, data, node);
				}
			}
			if(fs.isFile(x + $extensions.source)) {
				return $import.loadKSFile(x + $extensions.source, moduleName, module, data, node);
			}
			else {
				var __ks_0 = require.extensions;
				for(var ext in __ks_0) {
					if(fs.isFile(x + ext)) {
						return $import.loadNodeFile(x, moduleName, module, data, node);
					}
				}
			}
			return false;
		},
		loadKSFile() {
			if(arguments.length < 4) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var x = arguments[++__ks_i];
			if(arguments.length > 4) {
				var moduleName = arguments[++__ks_i];
			}
			else  {
				var moduleName = null;
			}
			var module = arguments[++__ks_i];
			var data = arguments[++__ks_i];
			var node = arguments[++__ks_i];
			if(!moduleName) {
				moduleName = module.path(x, data.module);
			}
			var metadata;
			var name;
			var alias;
			var variable;
			var exp;
			var source = fs.readFile(x);
			var __ks_0;
			if(fs.isFile(x + $extensions.metadata) && fs.isFile(x + $extensions.hash) && (fs.readFile(x + $extensions.hash) === fs.sha256(source)) && (Type.isValue(__ks_0 = $import.readMetadata(x)) ? (metadata = __ks_0, true) : false)) {
			}
			else {
				var compiler = new Compiler(x);
				compiler.compile(source);
				compiler.writeFiles();
				metadata = compiler.toMetadata();
			}
			var {exports, requirements} = metadata;
			var importVariables = {};
			var importVarCount = 0;
			var importAll = false;
			var importAlias = "";
			var __ks_0 = data.specifiers;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, specifier; __ks_1 < __ks_2; ++__ks_1) {
				specifier = __ks_0[__ks_1];
				if(specifier.kind === Kind.ImportWildcardSpecifier) {
					if(specifier.local) {
						importAlias = specifier.local.name;
					}
					else {
						importAll = true;
					}
				}
				else {
					importVariables[specifier.alias.name] = (specifier.local) ? (specifier.local.name) : (specifier.alias.name);
					++importVarCount;
				}
			}
			var importCode;
			if((importVarCount && importAll) || (importVarCount && importAlias.length) || (importAll && importAlias.length)) {
				importCode = node.newTempName();
				var __ks_exp_1 = node.newExpression().code("var ", importCode, " = require(", $quote(moduleName), ")(");
				var nf = false;
				for(name in requirements) {
					if(nf) {
						__ks_exp_1.code(", ");
					}
					else {
						nf = true;
					}
					__ks_exp_1.code(name);
					if(requirements[name].class) {
						__ks_exp_1.code(", __ks_", name);
					}
				}
				__ks_exp_1.code(")");
			}
			else if(importVarCount || importAll || importAlias.length) {
				importCode = "require(" + $quote(moduleName) + ")(";
				var nf = false;
				for(name in requirements) {
					if(nf) {
						importCode += ", ";
					}
					else {
						nf = true;
					}
					importCode += name;
					if(requirements[name].class) {
						importCode += ", __ks_" + name;
					}
				}
				importCode += ")";
			}
			if(importVarCount === 1) {
				for(name in importVariables) {
					alias = importVariables[name];
				}
				var __ks_1;
				if(!(Type.isValue(__ks_1 = exports[name]) ? variable = __ks_1 : undefined)) {
					throw new Error("Undefined variable " + name + " in the imported module at line " + data.start.line);
				}
				$import.addVariable(module, node, alias, variable);
				if(variable.kind !== VariableKind.TypeAlias) {
					if((variable.kind === VariableKind.Class) && variable.final) {
						variable.final.name = "__ks_" + alias;
						node.newExpression().code("var {" + alias + ", " + variable.final.name + "} = " + importCode);
					}
					else {
						node.newExpression().code("var " + alias + " = " + importCode + "." + name);
					}
				}
			}
			else if(importVarCount) {
				exp = node.newExpression().code("var {");
				var nf = false;
				for(name in importVariables) {
					alias = importVariables[name];
					var __ks_1;
					if(!(Type.isValue(__ks_1 = exports[name]) ? variable = __ks_1 : undefined)) {
						throw new Error("Undefined variable " + name + " in the imported module at line " + data.start.line);
					}
					$import.addVariable(module, node, alias, variable);
					if(variable.kind !== VariableKind.TypeAlias) {
						if(nf) {
							exp.code(", ");
						}
						else {
							nf = true;
						}
						if(alias === name) {
							exp.code(name);
							if((variable.kind === VariableKind.Class) && variable.final) {
								exp.code(", ", variable.final.name);
							}
						}
						else {
							exp.code(name, ": ", alias);
							if((variable.kind === VariableKind.Class) && variable.final) {
								variable.final.name = "__ks_" + alias;
								exp.code(", ", variable.final.name);
							}
						}
					}
				}
				exp.code("} = ", importCode);
			}
			if(importAll) {
				var variables = [];
				for(name in exports) {
					variable = exports[name];
					$import.addVariable(module, node, name, variable);
					if(variable.kind !== VariableKind.TypeAlias) {
						variables.push(name);
						if((variable.kind === VariableKind.Class) && variable.final) {
							variable.final.name = "__ks_" + name;
							variables.push(variable.final.name);
						}
					}
				}
				if(variables.length === 1) {
					node.newExpression().code("var ", variables[0], " = ", importCode, "." + variables[0]);
				}
				else if(variables.length) {
					exp = node.newExpression().code("var {");
					var nf = false;
					for(var __ks_1 = 0, __ks_2 = variables.length; __ks_1 < __ks_2; ++__ks_1) {
						name = variables[__ks_1];
						if(nf) {
							exp.code(", ");
						}
						else {
							nf = true;
						}
						exp.code(name);
					}
					exp.code("} = ", importCode);
				}
			}
			if(importAlias.length) {
				node.newExpression().code("var ", importAlias, " = ", importCode);
				var type = {
					typeName: {
						kind: Kind.Identifier,
						name: "Object"
					},
					properties: []
				};
				for(name in exports) {
					variable = exports[name];
					variable.name = {
						kind: Kind.Identifier,
						name: variable.name
					};
					type.properties.push(variable);
				}
				variable = $variable.define(node, {
					kind: Kind.Identifier,
					name: importAlias
				}, VariableKind.Variable, type);
			}
			return true;
		},
		loadNodeFile() {
			if(arguments.length < 3) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			if(arguments.length > 3) {
				var x = arguments[++__ks_i];
			}
			else  {
				var x = null;
			}
			if(arguments.length > 4) {
				var moduleName = arguments[++__ks_i];
			}
			else  {
				var moduleName = null;
			}
			var module = arguments[++__ks_i];
			var data = arguments[++__ks_i];
			var node = arguments[++__ks_i];
			if(!moduleName) {
				moduleName = module.path(x, data.module);
			}
			var variables = {};
			var count = 0;
			var __ks_0 = data.specifiers;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, specifier; __ks_1 < __ks_2; ++__ks_1) {
				specifier = __ks_0[__ks_1];
				if(specifier.kind === Kind.ImportWildcardSpecifier) {
					if(specifier.local) {
						node.newExpression().code("var ", specifier.local.name, " = require(", $quote(moduleName), ")");
						$import.define(module, node, specifier.local, VariableKind.Variable);
					}
					else {
						throw new Error("Wilcard import is only suppoted for ks files");
					}
				}
				else {
					variables[specifier.alias.name] = (specifier.local) ? (specifier.local.name) : (specifier.alias.name);
					++count;
				}
			}
			if(count === 1) {
				var alias;
				for(alias in variables) {
				}
				node.newExpression().code("var ", variables[alias], " = require(", $quote(moduleName), ").", alias);
				$import.define(module, node, variables[alias], VariableKind.Variable);
			}
			else if(count) {
				var exp = node.newExpression().code("var {");
				var nf = false;
				for(var alias in variables) {
					if(nf) {
						exp.code(", ");
					}
					else {
						nf = true;
					}
					if(variables[alias] === alias) {
						exp.code(alias);
					}
					else {
						exp.code(alias, ": ", variables[alias]);
					}
					$import.define(module, node, variables[alias], VariableKind.Variable);
				}
				exp.code("} = require(", $quote(moduleName), ")");
			}
			return true;
		},
		loadNodeModule(x, start, module, data, node) {
			if(x === undefined || x === null) {
				throw new Error("Missing parameter 'x'");
			}
			if(start === undefined || start === null) {
				throw new Error("Missing parameter 'start'");
			}
			if(module === undefined || module === null) {
				throw new Error("Missing parameter 'module'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var dirs = $import.nodeModulesPaths(start);
			var file;
			for(var __ks_0 = 0, __ks_1 = dirs.length, dir; __ks_0 < __ks_1; ++__ks_0) {
				dir = dirs[__ks_0];
				file = path.join(dir, x);
				if($import.loadFile(file, x, module, data, node) || $import.loadDirectory(file, x, module, data, node)) {
					return true;
				}
			}
			return false;
		},
		nodeModulesPaths(start) {
			if(start === undefined || start === null) {
				throw new Error("Missing parameter 'start'");
			}
			start = fs.resolve(start);
			var prefix = "/";
			if(/^([A-Za-z]:)/.test(start)) {
				prefix = "";
			}
			else if(/^\\\\/.test(start)) {
				prefix = "\\\\";
			}
			var splitRe = (process.platform === "win32") ? (/[\/\\]/) : (/\/+/);
			var parts = start.split(splitRe);
			var dirs = [];
			for(var i = parts.length - 1; i >= 0; --i) {
				if(parts[i] === "node_modules") {
					continue;
				}
				dirs.push(prefix + path.join(path.join.apply(path, parts.slice(0, i + 1)), "node_modules"));
			}
			if(process.platform === "win32") {
				dirs[dirs.length - 1] = dirs[dirs.length - 1].replace(":", ":\\");
			}
			return dirs;
		},
		readMetadata(x) {
			if(x === undefined || x === null) {
				throw new Error("Missing parameter 'x'");
			}
			try {
				return JSON.parse(fs.readFile(x + $extensions.metadata));
			}
			catch(__ks_0) {
				return null;
			}
		},
		resolve(data, y, module, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(y === undefined || y === null) {
				throw new Error("Missing parameter 'y'");
			}
			if(module === undefined || module === null) {
				throw new Error("Missing parameter 'module'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var x = data.module;
			if(/^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(x)) {
				x = fs.resolve(y, x);
				if(!($import.loadFile(x, null, module, data, node) || $import.loadDirectory(x, null, module, data, node))) {
					throw new Error("Cannot find module '" + x + "' from '" + y + "'");
				}
			}
			else {
				if(!($import.loadNodeModule(x, y, module, data, node) || $import.loadCoreModule(x, module, data, node))) {
					throw new Error("Cannot find module '" + x + "' from '" + y + "'");
				}
			}
		}
	};
	var $method = {
		fields(node, parameters, config, clazz) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(parameters === undefined || parameters === null) {
				throw new Error("Missing parameter 'parameters'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			var nf;
			var j;
			var exp;
			for(var __ks_0 = 0, __ks_1 = parameters.length, parameter; __ks_0 < __ks_1; ++__ks_0) {
				parameter = parameters[__ks_0];
				nf = true;
				for(var j = 0, __ks_2 = parameter.modifiers.length; nf && j < __ks_2; ++j) {
					if(parameter.modifiers[j].kind === ParameterModifier.Member) {
						$method.setMember(node, parameter.name.name, parameter.name, config, clazz);
						nf = false;
					}
				}
			}
		},
		parameters(node, config, parameters, signature) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(parameters === undefined || parameters === null) {
				throw new Error("Missing parameter 'parameters'");
			}
			if(signature === undefined || signature === null) {
				throw new Error("Missing parameter 'signature'");
			}
			if((signature.max < Infinity) || signature.parameters.last().rest) {
				for(var i = 0, __ks_0 = parameters.length, parameter; i < __ks_0; ++i) {
					parameter = parameters[i];
					if(i) {
						node.code(", ");
					}
					if(signature.parameters[i].rest) {
						node.code("...");
					}
					node.parameter(parameter.name, config);
					if(parameter.defaultValue && (!parameter.type || !parameter.type.nullable)) {
						node.code(" = ").compile(parameter.defaultValue, config);
					}
				}
			}
			else {
				for(var i = 0, __ks_0 = parameters.length, parameter; i < __ks_0; ++i) {
					parameter = parameters[i];
					if(i) {
						node.code(", ");
					}
					node.parameter(parameter.name, config);
					if(parameter.defaultValue && (!parameter.type || !parameter.type.nullable)) {
						node.code(" = ").compile(parameter.defaultValue, config);
					}
				}
			}
		},
		prepare(data, methods, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(methods === undefined || methods === null) {
				throw new Error("Missing parameter 'methods'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			methods.push({
				data: data,
				signature: $method.signature(data, node)
			});
		},
		sameType(s1, s2) {
			if(s1 === undefined || s1 === null) {
				throw new Error("Missing parameter 's1'");
			}
			if(s2 === undefined || s2 === null) {
				throw new Error("Missing parameter 's2'");
			}
			if(Type.isArray(s1)) {
				if((Type.isArray(s2)) && (s1.length === s2.length)) {
					for(var i = 0, __ks_0 = s1.length; i < __ks_0; ++i) {
						if(!$method.sameType(s1[i], s2[i])) {
							return false;
						}
					}
					return true;
				}
				else {
					return false;
				}
			}
			else {
				return s1 === s2;
			}
		},
		setMember(node, name, data, config, clazz) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(clazz === undefined || clazz === null) {
				throw new Error("Missing parameter 'clazz'");
			}
			if(clazz.instanceVariables[name]) {
				node.newExpression().code("this." + name + " = ").compile(data, config);
			}
			else if(clazz.instanceVariables["_" + name]) {
				node.newExpression().code("this._" + name + " = ").compile(data, config);
			}
			else if(clazz.instanceMethods[name] && clazz.instanceMethods[name]["1"]) {
				node.newExpression().code("this." + name + "(").compile(data, config).code(")");
			}
			else {
				throw new Error("Can't set member " + name + " (line " + data.start.line + ")");
			}
		},
		signature(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var signature = {
				access: MemberAccess.Public,
				min: 0,
				max: 0,
				parameters: []
			};
			if(data.modifiers) {
				var __ks_0 = data.modifiers;
				for(var __ks_1 = 0, __ks_2 = __ks_0.length, modifier; __ks_1 < __ks_2; ++__ks_1) {
					modifier = __ks_0[__ks_1];
					if(modifier.kind === FunctionModifier.Async) {
						signature.async = true;
					}
					else if(modifier.kind === MemberModifier.Private) {
						signature.access = MemberAccess.Private;
					}
					else if(modifier.kind === MemberModifier.Protected) {
						signature.access = MemberAccess.Protected;
					}
				}
			}
			var type;
			var last;
			var nf;
			var __ks_0 = data.parameters;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, parameter; __ks_1 < __ks_2; ++__ks_1) {
				parameter = __ks_0[__ks_1];
				type = $signature.type(parameter.type, node);
				if(!last || !$method.sameType(type, last.type)) {
					if(last) {
						signature.min += last.min;
						signature.max += last.max;
					}
					last = {
						type: $signature.type(parameter.type, node),
						min: (parameter.defaultValue || (parameter.type && parameter.type.nullable)) ? (0) : (1),
						max: 1
					};
					if(parameter.modifiers) {
						var __ks_3 = parameter.modifiers;
						for(var __ks_4 = 0, __ks_5 = __ks_3.length, modifier; __ks_4 < __ks_5; ++__ks_4) {
							modifier = __ks_3[__ks_4];
							if(modifier.kind === ParameterModifier.Rest) {
								if(modifier.arity) {
									last.min += modifier.arity.min;
									last.max += modifier.arity.max;
								}
								else {
									last.max = Infinity;
								}
							}
						}
					}
					signature.parameters.push(last);
				}
				else {
					nf = true;
					if(parameter.modifiers) {
						var __ks_3 = parameter.modifiers;
						for(var __ks_4 = 0, __ks_5 = __ks_3.length, modifier; __ks_4 < __ks_5; ++__ks_4) {
							modifier = __ks_3[__ks_4];
							if(modifier.kind === ParameterModifier.Rest) {
								if(modifier.arity) {
									last.min += modifier.arity.min;
									last.max += modifier.arity.max;
								}
								else {
									last.max = Infinity;
								}
								nf = false;
							}
						}
					}
					if(nf) {
						if(!(parameter.defaultValue || (parameter.type && parameter.type.nullable))) {
							++last.min;
						}
						++last.max;
					}
				}
			}
			if(last) {
				signature.min += last.min;
				signature.max += last.max;
			}
			return signature;
		}
	};
	var $operator = {
		binaries: {},
		lefts: {},
		numerics: {},
		assignment(node, data, config, mode) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			var __ks_0 = data.operator.assignment;
			if(__ks_0 === AssignmentOperator.Addition) {
				node.assignment(data).compile(data.left, config, Mode.Key).code(" += ").compile(data.right, config, Mode.Assignment);
			}
			else if(__ks_0 === AssignmentOperator.BitwiseOr) {
				node.assignment(data).compile(data.left, config, Mode.Key).code(" |= ").compile(data.right, config, Mode.Assignment);
			}
			else if(__ks_0 === AssignmentOperator.BitwiseXor) {
				node.assignment(data).compile(data.left, config, Mode.Key).code(" ^= ").compile(data.right, config, Mode.Assignment);
			}
			else if(__ks_0 === AssignmentOperator.Equality) {
				node.assignment(data);
				if(mode & Mode.BooleanExpression) {
					node.code("(").compile(data.left, config, Mode.Key).code(" = ").compile(data.right, config, Mode.Assignment).code(")");
				}
				else {
					node.compile(data.left, config, Mode.Key).code(" = ").compile(data.right, config, Mode.Assignment);
				}
			}
			else if(__ks_0 === AssignmentOperator.Existential) {
				node.assignment(data, true);
				if(data.right.kind === Kind.Identifier) {
					if(mode & Mode.BooleanExpression) {
						node.code("Type.isValue(").compile(data.right, config, Mode.Key).code(") ? (").compile(data.left, config, Mode.Key).code(" = ").compile(data.right, config, Mode.Assignment).code(", true) : false");
					}
					else {
						node.code("Type.isValue(").compile(data.right, config, Mode.Key).code(") ? ").compile(data.left, config, Mode.Key).code(" = ").compile(data.right, config, Mode.Assignment).code(" : undefined");
					}
				}
				else {
					var name = node.newTempName();
					if(mode & Mode.BooleanExpression) {
						node.code("Type.isValue(", name, " = ").compile(data.right, config, Mode.Key).code(") ? (").compile(data.left, config, Mode.Key).code(" = ", name, ", true) : false");
					}
					else {
						node.code("Type.isValue(", name, " = ").compile(data.right, config, Mode.Key).code(") ? ").compile(data.left, config, Mode.Key).code(" = ", name, " : undefined");
					}
				}
			}
			else if(__ks_0 === AssignmentOperator.Subtraction) {
				node.assignment(data).compile(data.left, config, Mode.Key).code(" -= ").compile(data.right, config, Mode.Assignment);
			}
			else {
				console.error(data);
				throw new Error("Unknow assignment operator " + data.operator.assignment);
			}
		},
		binary(node, data, config, mode) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			var __ks_0 = data.operator.kind;
			if(__ks_0 === BinaryOperator.And) {
				node.compile(data.left, config, (mode | Mode.Operand) | Mode.BooleanExpression).code(" && ").compile(data.right, config, (mode | Mode.Operand) | Mode.BooleanExpression);
			}
			else if(__ks_0 === BinaryOperator.Addition) {
				node.compile(data.left, config, Mode.Operand).code(" + ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.BitwiseAnd) {
				node.compile(data.left, config, Mode.Operand).code(" & ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.BitwiseLeftShift) {
				node.compile(data.left, config, Mode.Operand).code(" << ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.BitwiseOr) {
				node.compile(data.left, config, Mode.Operand).code(" | ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.BitwiseRightShift) {
				node.compile(data.left, config, Mode.Operand).code(" >> ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.BitwiseXor) {
				node.compile(data.left, config, Mode.Operand).code(" ^ ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Division) {
				node.compile(data.left, config, Mode.Operand).code(" / ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Equality) {
				node.compile(data.left, config, Mode.Operand).code(" === ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Existential) {
				if(data.left.kind === data.right.kind && data.right.kind === Kind.Identifier) {
					node.code("Type.isValue(").compile(data.left, config, Mode.Operand).code(") ? ").compile(data.left, config, Mode.Operand).code(" : ").compile(data.right, config, Mode.Operand);
				}
				else {
					node.code("Type.vexists(").compile(data.left, config, Mode.Operand).code(", ").compile(data.right, config, Mode.Operand).code(")");
				}
			}
			else if(__ks_0 === BinaryOperator.GreaterThan) {
				node.compile(data.left, config, Mode.Operand).code(" > ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.GreaterThanOrEqual) {
				node.compile(data.left, config, Mode.Operand).code(" >= ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Inequality) {
				node.compile(data.left, config, Mode.Operand).code(" !== ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.LessThan) {
				node.compile(data.left, config, Mode.Operand).code(" < ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.LessThanOrEqual) {
				node.compile(data.left, config, Mode.Operand).code(" <= ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Modulo) {
				node.compile(data.left, config, Mode.Operand).code(" % ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Multiplication) {
				node.compile(data.left, config, Mode.Operand).code(" * ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.Or) {
				node.compile(data.left, config, (mode | Mode.Operand) | Mode.BooleanExpression).code(" || ").compile(data.right, config, (mode | Mode.Operand) | Mode.BooleanExpression);
			}
			else if(__ks_0 === BinaryOperator.Subtraction) {
				node.compile(data.left, config, Mode.Operand).code(" - ").compile(data.right, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.TypeCast) {
				node.compile(data.left, config, Mode.Operand);
			}
			else if(__ks_0 === BinaryOperator.TypeCheck) {
				$type.check(node, data.left, data.right, config);
			}
			else {
				console.error(data);
				throw new Error("Unknow binary operator " + data.operator.kind);
			}
		},
		polyadic(node, data, config, mode) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			var __ks_0 = data.operator.kind;
			if(__ks_0 === BinaryOperator.And) {
				for(var i = 0, __ks_1 = data.operands.length; i < __ks_1; ++i) {
					if(i) {
						node.code(" && ");
					}
					node.compile(data.operands[i], config, (mode | Mode.Operand) | Mode.BooleanExpression);
				}
			}
			else if(__ks_0 === BinaryOperator.Addition) {
				for(var i = 0, __ks_1 = data.operands.length; i < __ks_1; ++i) {
					if(i) {
						node.code(" + ");
					}
					node.compile(data.operands[i], config, Mode.Operand);
				}
			}
			else if(__ks_0 === BinaryOperator.Equality) {
				for(var i = 0, __ks_1 = data.operands.length - 1; i < __ks_1; ++i) {
					if(i) {
						node.code(" && ");
					}
					node.compile(data.operands[i], config, Mode.Operand);
					node.code(" === ");
					node.compile(data.operands[i + 1], config, Mode.Operand);
				}
			}
			else if(__ks_0 === BinaryOperator.Existential) {
				node.code("Type.vexists(");
				for(var i = 0, __ks_1 = data.operands.length; i < __ks_1; ++i) {
					if(i) {
						node.code(", ");
					}
					node.compile(data.operands[i], config, Mode.Operand);
				}
				node.code(")");
			}
			else if(__ks_0 === BinaryOperator.LessThanOrEqual) {
				for(var i = 0, __ks_1 = data.operands.length - 1; i < __ks_1; ++i) {
					if(i) {
						node.code(" && ");
					}
					node.compile(data.operands[i], config, Mode.Operand);
					node.code(" <= ");
					node.compile(data.operands[i + 1], config, Mode.Operand);
				}
			}
			else if(__ks_0 === BinaryOperator.Multiplication) {
				for(var i = 0, __ks_1 = data.operands.length; i < __ks_1; ++i) {
					if(i) {
						node.code(" * ");
					}
					node.compile(data.operands[i], config, Mode.Operand);
				}
			}
			else if(__ks_0 === BinaryOperator.Or) {
				for(var i = 0, __ks_1 = data.operands.length; i < __ks_1; ++i) {
					if(i) {
						node.code(" || ");
					}
					node.compile(data.operands[i], config, (mode | Mode.Operand) | Mode.BooleanExpression);
				}
			}
			else {
				console.error(data);
				throw new Error("Unknow polyadic operator " + data.operator.kind);
			}
		},
		unary(node, data, config, mode) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			var __ks_0 = data.operator.kind;
			if(__ks_0 === UnaryOperator.DecrementPostfix) {
				node.compile(data.argument, config, Mode.Operand).code("--");
			}
			else if(__ks_0 === UnaryOperator.DecrementPrefix) {
				node.code("--").compile(data.argument, config, Mode.Operand);
			}
			else if(__ks_0 === UnaryOperator.Existential) {
				node.code("Type.isValue(").compile(data.argument, config, Mode.Operand).code(")");
			}
			else if(__ks_0 === UnaryOperator.IncrementPostfix) {
				node.compile(data.argument, config, Mode.Operand).code("++");
			}
			else if(__ks_0 === UnaryOperator.IncrementPrefix) {
				node.code("++").compile(data.argument, config, Mode.Operand);
			}
			else if(__ks_0 === UnaryOperator.Negation) {
				node.code("!").compile(data.argument, config, Mode.Operand);
			}
			else if(__ks_0 === UnaryOperator.Negative) {
				node.code("-").compile(data.argument, config, Mode.Operand);
			}
			else if(__ks_0 === UnaryOperator.New) {
				node.code("new ").compile(data.argument, config, Mode.Operand);
			}
			else {
				console.error(data);
				throw new Error("Unknow unary operator " + data.operator.kind);
			}
		}
	};
	$operator.binaries[BinaryOperator.And] = true;
	$operator.binaries[BinaryOperator.Equality] = true;
	$operator.binaries[BinaryOperator.Existential] = true;
	$operator.binaries[BinaryOperator.GreaterThan] = true;
	$operator.binaries[BinaryOperator.GreaterThanOrEqual] = true;
	$operator.binaries[BinaryOperator.Inequality] = true;
	$operator.binaries[BinaryOperator.LessThan] = true;
	$operator.binaries[BinaryOperator.LessThanOrEqual] = true;
	$operator.binaries[BinaryOperator.Or] = true;
	$operator.binaries[BinaryOperator.TypeCheck] = true;
	$operator.lefts[BinaryOperator.Addition] = true;
	$operator.lefts[BinaryOperator.Assignment] = true;
	$operator.numerics[BinaryOperator.BitwiseAnd] = true;
	$operator.numerics[BinaryOperator.BitwiseLeftShift] = true;
	$operator.numerics[BinaryOperator.BitwiseOr] = true;
	$operator.numerics[BinaryOperator.BitwiseRightShift] = true;
	$operator.numerics[BinaryOperator.BitwiseXor] = true;
	$operator.numerics[BinaryOperator.Division] = true;
	$operator.numerics[BinaryOperator.Modulo] = true;
	$operator.numerics[BinaryOperator.Multiplication] = true;
	$operator.numerics[BinaryOperator.Subtraction] = true;
	function $quote(value) {
		if(value === undefined || value === null) {
			throw new Error("Missing parameter 'value'");
		}
		return "\"" + value.replace(/"/g, "\\\"") + "\"";
	}
	var $signature = {
		type() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			if(arguments.length > 1) {
				var type = arguments[++__ks_i];
			}
			else  {
				var type = null;
			}
			var node = arguments[++__ks_i];
			if(type) {
				if(type.typeName) {
					if($types[type.typeName.name]) {
						return $types[type.typeName.name];
					}
					var variable, __ks_0;
					if((Type.isValue(__ks_0 = node.getVariable(type.typeName.name)) ? (variable = __ks_0, true) : false) && (variable.kind === VariableKind.TypeAlias)) {
						return $signature.type(variable.type, node);
					}
					return type.typeName.name;
				}
				else if(type.types) {
					var types = [];
					for(var i = 0, __ks_0 = type.types.length; i < __ks_0; ++i) {
						types.push($signature.type(type.types[i], node));
					}
					return types;
				}
				else {
					console.error(type);
					throw new Error("Not Implemented");
				}
			}
			else {
				return "Any";
			}
		}
	};
	var $switch = {
		binding(clause, ctrl, name, config) {
			if(clause === undefined || clause === null) {
				throw new Error("Missing parameter 'clause'");
			}
			if(ctrl === undefined || ctrl === null) {
				throw new Error("Missing parameter 'ctrl'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			var __ks_0 = clause.bindings;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, binding; __ks_1 < __ks_2; ++__ks_1) {
				binding = __ks_0[__ks_1];
				if(binding.kind === Kind.ArrayBinding) {
					ctrl.newExpression().code("var ").compile(binding, config).code(" = ", name);
				}
				else if(binding.kind === Kind.ObjectBinding) {
					console.error(binding);
					throw new Error("Not Implemented");
				}
				else if(binding.kind === Kind.SwitchTypeCast) {
					ctrl.newExpression().code($variable.scope(config), binding.name.name, " = ", name);
					$variable.define(ctrl, binding.name, VariableKind.Variable);
				}
				else {
					ctrl.newExpression().code($variable.scope(config), binding.name, " = ", name);
					$variable.define(ctrl, binding, VariableKind.Variable);
				}
			}
		},
		length(elements) {
			if(elements === undefined || elements === null) {
				throw new Error("Missing parameter 'elements'");
			}
			var min = 0;
			var max = 0;
			for(var __ks_0 = 0, __ks_1 = elements.length, element; __ks_0 < __ks_1; ++__ks_0) {
				element = elements[__ks_0];
				if(element.spread) {
					max = Infinity;
				}
				else {
					++min;
					++max;
				}
			}
			return {
				min: min,
				max: max
			};
		},
		test() {
			if(arguments.length < 5) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var clause = arguments[++__ks_i];
			var ctrl = arguments[++__ks_i];
			var name = arguments[++__ks_i];
			if(arguments.length > 5) {
				var filter = arguments[++__ks_i];
			}
			else  {
				var filter = null;
			}
			var nf = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			var mm;
			var __ks_0 = clause.bindings;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, binding; __ks_1 < __ks_2; ++__ks_1) {
				binding = __ks_0[__ks_1];
				if(binding.kind === Kind.ArrayBinding) {
					if(nf) {
						ctrl.code(" && ");
					}
					else {
						nf = true;
					}
					ctrl.code($typeofs.Array, "(", name, ")");
					mm = $switch.length(binding.elements);
					if(mm.min === mm.max) {
						if(mm.min !== Infinity) {
							ctrl.code(" && ", name, ".length === ", mm.min);
						}
					}
					else {
						ctrl.code(" && ", name, ".length >= ", mm.min);
						if(mm.max !== Infinity) {
							ctrl.code(" && ", name, ".length <= ", mm.max);
						}
					}
				}
				else if(binding.kind === Kind.ObjectBinding) {
					console.error(binding);
					throw new Error("Not Implemented");
				}
			}
			if(clause.filter) {
				if(nf) {
					ctrl.code(" && ");
				}
				if(filter) {
					ctrl.code(filter, "(", name, ")");
				}
				else {
					ctrl.compile(clause.filter, config);
				}
			}
		}
	};
	function $toInt(data, defaultValue) {
		if(data === undefined || data === null) {
			throw new Error("Missing parameter 'data'");
		}
		if(defaultValue === undefined || defaultValue === null) {
			throw new Error("Missing parameter 'defaultValue'");
		}
		var __ks_0 = data.kind;
		if(__ks_0 === Kind.NumericExpression) {
			return data.value;
		}
		else {
			return defaultValue;
		}
	}
	var $type = {
		check(node, name, type, config) {
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(type === undefined || type === null) {
				throw new Error("Missing parameter 'type'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			if(type.kind === Kind.TypeReference) {
				type = $type.unalias(type, node);
				if(type.typeParameters) {
					if($generics[type.typeName.name] || !$types[type.typeName.name] || $generics[$types[type.typeName.name]]) {
						var tof = $typeofs[type.typeName.name] || $typeofs[$types[type.typeName.name]];
						if(tof) {
							node.code(tof + "(").compile(name, config, Mode.Operand);
							var __ks_0 = type.typeParameters;
							for(var __ks_1 = 0, __ks_2 = __ks_0.length, typeParameter; __ks_1 < __ks_2; ++__ks_1) {
								typeParameter = __ks_0[__ks_1];
								node.code(", ").compile(typeParameter, config);
							}
							node.code(")");
						}
						else {
							node.code("Type.is(").compile(name, config, Mode.Operand).code(", ").compile(type.typeName, config, Mode.Operand);
							var __ks_0 = type.typeParameters;
							for(var __ks_1 = 0, __ks_2 = __ks_0.length, typeParameter; __ks_1 < __ks_2; ++__ks_1) {
								typeParameter = __ks_0[__ks_1];
								node.code(", ").compile(typeParameter, config);
							}
							node.code(")");
						}
					}
					else {
						throw new Error("Generic on primitive at line " + type.start.line);
					}
				}
				else {
					var tof = $typeofs[type.typeName.name] || $typeofs[$types[type.typeName.name]];
					if(tof) {
						node.code(tof + "(").compile(name, config, Mode.Operand).code(")");
					}
					else {
						node.code("Type.is(").compile(name, config, Mode.Operand).code(", ").compile(type, config, Mode.Operand).code(")");
					}
				}
			}
			else if(type.types) {
				node.code("(");
				for(var i = 0, __ks_0 = type.types.length; i < __ks_0; ++i) {
					if(i) {
						node.code(" || ");
					}
					$type.check(node, name, type.types[i], config);
				}
				node.code(")");
			}
			else {
				console.error(type);
				throw new Error("Not Implemented");
			}
		},
		isAny(type = null) {
			if(!type) {
				return true;
			}
			if((type.kind === Kind.TypeReference) && (type.typeName.kind === Kind.Identifier) && ((type.typeName.name === "any") || (type.typeName.name === "Any"))) {
				return true;
			}
			return false;
		},
		reference(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(Type.isString(name)) {
				return {
					kind: Kind.TypeReference,
					typeName: {
						kind: Kind.Identifier,
						name: name
					}
				};
			}
			else {
				return {
					kind: Kind.TypeReference,
					typeName: name
				};
			}
		},
		same(a, b) {
			if(a === undefined || a === null) {
				throw new Error("Missing parameter 'a'");
			}
			if(b === undefined || b === null) {
				throw new Error("Missing parameter 'b'");
			}
			if(a.kind !== b.kind) {
				return false;
			}
			if(a.kind === Kind.TypeReference) {
				if(a.typeName.kind !== b.typeName.kind) {
					return false;
				}
				if(a.typeName.kind === Kind.Identifier) {
					if(a.typeName.name !== b.typeName.name) {
						return false;
					}
				}
			}
			return true;
		},
		type(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(!data.kind) {
				return data;
			}
			var type = null;
			var __ks_0 = data.kind;
			if(__ks_0 === Kind.BinaryOperator) {
				if(data.operator.kind === BinaryOperator.TypeCast) {
					return $type.type(data.right);
				}
				else if($operator.binaries[data.operator.kind]) {
					return {
						typeName: {
							kind: Kind.Identifier,
							name: "Boolean"
						}
					};
				}
				else if($operator.lefts[data.operator.kind]) {
					return $type.type(data.left, node);
				}
				else if($operator.numerics[data.operator.kind]) {
					return {
						typeName: {
							kind: Kind.Identifier,
							name: "Number"
						}
					};
				}
			}
			else if(__ks_0 === Kind.Identifier) {
				var variable = node.getVariable(data.name);
				if(variable && variable.type) {
					return variable.type;
				}
			}
			else if(__ks_0 === Kind.Literal) {
				return {
					typeName: {
						kind: Kind.Identifier,
						name: $literalTypes[data.value] || "String"
					}
				};
			}
			else if(__ks_0 === Kind.NumericExpression) {
				return {
					typeName: {
						kind: Kind.Identifier,
						name: "Number"
					}
				};
			}
			else if(__ks_0 === Kind.ObjectExpression) {
				type = {
					typeName: {
						kind: Kind.Identifier,
						name: "Object"
					},
					properties: []
				};
				var prop;
				var __ks_1 = data.properties;
				for(var __ks_2 = 0, __ks_3 = __ks_1.length, property; __ks_2 < __ks_3; ++__ks_2) {
					property = __ks_1[__ks_2];
					prop = {
						name: {
							kind: Kind.Identifier,
							name: property.name.name
						}
					};
					if(property.value.kind === Kind.FunctionExpression) {
						prop.signature = $function.signature(property.value, node);
						if(property.value.type) {
							prop.type = $type.type(property.value.type, node);
						}
					}
					type.properties.push(prop);
				}
			}
			else if(__ks_0 === Kind.Template) {
				return {
					typeName: {
						kind: Kind.Identifier,
						name: "String"
					}
				};
			}
			else if(__ks_0 === Kind.TypeReference) {
				if(data.typeName) {
					if(data.properties) {
						type = {
							typeName: {
								kind: Kind.Identifier,
								name: "Object"
							},
							properties: []
						};
						var prop;
						var __ks_1 = data.properties;
						for(var __ks_2 = 0, __ks_3 = __ks_1.length, property; __ks_2 < __ks_3; ++__ks_2) {
							property = __ks_1[__ks_2];
							prop = {
								name: {
									kind: Kind.Identifier,
									name: property.name.name
								}
							};
							if(property.type) {
								prop.signature = $function.signature(property.type, node);
								if(property.type.type) {
									prop.type = $type.type(property.type.type, node);
								}
							}
							type.properties.push(prop);
						}
					}
					else {
						type = {
							typeName: $type.typeName(data.typeName)
						};
						if(data.nullable) {
							type.nullable = true;
						}
						if(data.typeParameters) {
							type.typeParameters = __ks_Array._cm_map(data.typeParameters, (parameter) => {
								return $type.type(parameter, node);
							});
						}
					}
				}
			}
			else if(__ks_0 === Kind.UnionType) {
				return {
					types: __ks_Array._cm_map(data.types, (type) => {
						return $type.type(type, node);
					})
				};
			}
			return type;
		},
		typeName(data) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(data.kind === Kind.Identifier) {
				return {
					kind: Kind.Identifier,
					name: data.name
				};
			}
			else {
				return {
					kind: Kind.MemberExpression,
					object: $type.typeName(data.object),
					property: $type.typeName(data.property),
					computed: false
				};
			}
		},
		unalias(type, node) {
			if(type === undefined || type === null) {
				throw new Error("Missing parameter 'type'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var variable = node.getVariable(type.typeName.name);
			if(variable && (variable.kind === VariableKind.TypeAlias)) {
				return $type.unalias(variable.type, node);
			}
			return type;
		}
	};
	var $variable = {
		define() {
			if(arguments.length < 3) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var node = arguments[++__ks_i];
			var name = arguments[++__ks_i];
			var kind = arguments[++__ks_i];
			if(arguments.length > 3) {
				var type = arguments[++__ks_i];
			}
			else  {
				var type = null;
			}
			var variable = node.getVariable(name.name || name);
			if(variable && (variable.kind === kind)) {
				variable.new = false;
			}
			else {
				node.addVariable(name.name || name, variable = {
					name: name,
					kind: kind,
					new: true
				});
				if(kind === VariableKind.Class) {
					variable.constructors = [];
					variable.instanceVariables = {};
					variable.classVariables = {};
					variable.instanceMethods = {};
					variable.classMethods = {};
				}
				else if(kind === VariableKind.Enum) {
					if(type) {
						if(type.typeName.name === "string") {
							variable.type = "string";
						}
					}
					if(!variable.type) {
						variable.type = "number";
						variable.counter = -1;
					}
				}
				else if(kind === VariableKind.TypeAlias) {
					variable.type = $type.type(type, node);
				}
				else if(((kind === VariableKind.Function) || (kind === VariableKind.Variable)) && type) {
					var __ks_0;
					if(Type.isValue(__ks_0 = $type.type(type, node)) ? (type = __ks_0, true) : false) {
						variable.type = type;
					}
				}
			}
			return variable;
		},
		filter(method, min, max) {
			if(method === undefined || method === null) {
				throw new Error("Missing parameter 'method'");
			}
			if(min === undefined || min === null) {
				throw new Error("Missing parameter 'min'");
			}
			if(max === undefined || max === null) {
				throw new Error("Missing parameter 'max'");
			}
			if(method.signature) {
				if((min >= method.signature.min) && (max <= method.signature.max)) {
					return true;
				}
			}
			else if(method.typeName) {
				if((method.typeName.name === "func") || (method.typeName.name === "Function")) {
					return true;
				}
				else {
					console.error(method);
					throw new Error("Not implemented");
				}
			}
			else {
				console.error(method);
				throw new Error("Not implemented");
			}
			return false;
		},
		filterType(variable, name, node) {
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(variable.type) {
				if(variable.type.properties) {
					var __ks_0 = variable.type.properties;
					for(var __ks_1 = 0, __ks_2 = __ks_0.length, property; __ks_1 < __ks_2; ++__ks_1) {
						property = __ks_0[__ks_1];
						if(property.name.name === name) {
							return variable;
						}
					}
				}
				else if(variable.type.typeName) {
					var __ks_0;
					if(Type.isValue(__ks_0 = $variable.fromType(variable.type, node)) ? (variable = __ks_0, true) : false) {
						return $variable.filterMember(variable, name, node);
					}
				}
				else if(variable.type.types) {
					var variables = [];
					var __ks_0 = variable.type.types;
					for(var __ks_1 = 0, __ks_2 = __ks_0.length, type; __ks_1 < __ks_2; ++__ks_1) {
						type = __ks_0[__ks_1];
						var __ks_3, __ks_4;
						if(!((Type.isValue(__ks_3 = $variable.fromType(type, node)) ? (variable = __ks_3, true) : false) && (Type.isValue(__ks_4 = $variable.filterMember(variable, name, node)) ? (variable = __ks_4, true) : false))) {
							return null;
						}
						variables.push(variable);
					}
					return variables;
				}
				else {
					console.error(variable);
					throw new Error("Not implemented");
				}
			}
			return null;
		},
		filterMember(variable, name, node) {
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(variable.kind === VariableKind.Class) {
				if(variable.instanceMethods[name]) {
					return variable;
				}
				else if(variable.instanceVariables[name] && variable.instanceVariables[name].type) {
					return $variable.fromReflectType(variable.instanceVariables[name].type, node);
				}
			}
			else if(variable.kind === VariableKind.Enum) {
				console.error(variable);
				throw new Error("Not implemented");
			}
			else if(variable.kind === VariableKind.TypeAlias) {
				if(variable.type.types) {
					var variables = [];
					var __ks_0 = variable.type.types;
					for(var __ks_1 = 0, __ks_2 = __ks_0.length, type; __ks_1 < __ks_2; ++__ks_1) {
						type = __ks_0[__ks_1];
						var __ks_3, __ks_4;
						if(!((Type.isValue(__ks_3 = $variable.fromType(type, node)) ? (variable = __ks_3, true) : false) && (Type.isValue(__ks_4 = $variable.filterMember(variable, name, node)) ? (variable = __ks_4, true) : false))) {
							return null;
						}
						variables.push(variable);
					}
					return variables;
				}
				else {
					var __ks_0;
					if(Type.isValue(__ks_0 = $variable.fromType(variable.type, node)) ? (variable = __ks_0, true) : false) {
						return $variable.filterMember(variable, name, node);
					}
				}
			}
			else if(variable.kind === VariableKind.Variable) {
				console.error(variable);
				throw new Error("Not implemented");
			}
			else {
				console.error(variable);
				throw new Error("Not implemented");
			}
			return null;
		},
		fromAST(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			var __ks_0 = data.kind;
			if(__ks_0 === Kind.BinaryOperator) {
				if(data.operator.kind === BinaryOperator.TypeCast) {
					return {
						kind: VariableKind.Variable,
						type: data.right
					};
				}
				else if($operator.binaries[data.operator.kind]) {
					return {
						kind: VariableKind.Variable,
						type: {
							kind: Kind.TypeReference,
							typeName: {
								kind: Kind.Identifier,
								name: "Boolean"
							}
						}
					};
				}
				else if($operator.lefts[data.operator.kind]) {
					var type = $type.type(data.left, node);
					if(type) {
						return {
							kind: VariableKind.Variable,
							type: type
						};
					}
				}
				else if($operator.numerics[data.operator.kind]) {
					return {
						kind: VariableKind.Variable,
						type: {
							kind: Kind.TypeReference,
							typeName: {
								kind: Kind.Identifier,
								name: "Number"
							}
						}
					};
				}
			}
			else if(__ks_0 === Kind.CallExpression) {
				var variable = $variable.fromAST(data.callee, node);
				if(variable) {
					if(data.callee.kind === Kind.Identifier) {
						if(variable.kind === VariableKind.Function) {
							return variable;
						}
					}
					else if(data.callee.kind === Kind.MemberExpression) {
						var min = 0;
						var max = 0;
						var __ks_1 = data.arguments;
						for(var __ks_2 = 0, __ks_3 = __ks_1.length, arg; __ks_2 < __ks_3; ++__ks_2) {
							arg = __ks_1[__ks_2];
							if(max === Infinity) {
								++min;
							}
							else if(arg.spread) {
								max = Infinity;
							}
							else {
								++min;
								++max;
							}
						}
						var variables = [];
						var name = data.callee.property.name;
						var varType;
						if(Type.isArray(variable)) {
							for(var __ks_2 = 0, __ks_3 = variable.length, vari; __ks_2 < __ks_3; ++__ks_2) {
								vari = variable[__ks_2];
								var __ks_4 = vari.instanceMethods[name];
								for(var __ks_5 = 0, __ks_6 = __ks_4.length, member; __ks_5 < __ks_6; ++__ks_5) {
									member = __ks_4[__ks_5];
									if(member.type && $variable.filter(member, min, max)) {
										varType = $variable.fromType(member.type, node);
										if(varType) {
											__ks_Array._im_pushUniq(variables, varType);
										}
									}
									else {
										return null;
									}
								}
							}
							if(variables.length === 1) {
								return variables[0];
							}
							if(variables) {
								return variables;
							}
						}
						else if(variable.kind === VariableKind.Class) {
							if(data.callee.object.kind === Kind.Identifier) {
								if(variable.classMethods[name]) {
									var __ks_2 = variable.classMethods[name];
									for(var __ks_3 = 0, __ks_4 = __ks_2.length, member; __ks_3 < __ks_4; ++__ks_3) {
										member = __ks_2[__ks_3];
										if(member.type && $variable.filter(member, min, max)) {
											varType = $variable.fromType(member.type, node);
											if(varType) {
												variables.push(varType);
											}
										}
									}
								}
							}
							else {
								if(variable.instanceMethods[name]) {
									var __ks_2 = variable.instanceMethods[name];
									for(var __ks_3 = 0, __ks_4 = __ks_2.length, member; __ks_3 < __ks_4; ++__ks_3) {
										member = __ks_2[__ks_3];
										if(member.type && $variable.filter(member, min, max)) {
											varType = $variable.fromType(member.type, node);
											if(varType) {
												variables.push(varType);
											}
										}
									}
								}
							}
						}
						else if(variable.kind === VariableKind.Variable) {
							if(variable.type && variable.type.properties) {
								var __ks_2 = variable.type.properties;
								for(var __ks_3 = 0, __ks_4 = __ks_2.length, property; __ks_3 < __ks_4; ++__ks_3) {
									property = __ks_2[__ks_3];
									if(property.type && (property.name.name === name) && $variable.filter(property, min, max)) {
										varType = $variable.fromType(property.type, node);
										if(varType) {
											variables.push(varType);
										}
									}
								}
							}
						}
						else {
							console.error(variable);
							throw new Error("Not implemented");
						}
						if(variables.length === 1) {
							return variables[0];
						}
					}
					else {
						console.error(data.callee);
						throw new Error("Not implemented");
					}
				}
			}
			else if(__ks_0 === Kind.Identifier) {
				return node.getVariable(data.name);
			}
			else if(__ks_0 === Kind.Literal) {
				return {
					kind: VariableKind.Variable,
					type: {
						kind: Kind.TypeReference,
						typeName: {
							kind: Kind.Identifier,
							name: $literalTypes[data.value] || "String"
						}
					}
				};
			}
			else if(__ks_0 === Kind.MemberExpression) {
				var variable = $variable.fromAST(data.object, node);
				if(variable) {
					if(data.computed) {
						if(variable.type && ((variable = $variable.fromType(variable.type, node))) && variable.type && ((variable = $variable.fromType(variable.type, node)))) {
							return variable;
						}
					}
					else {
						var name = data.property.name;
						if(variable.kind === VariableKind.Class) {
							if(data.object.kind === Kind.Identifier) {
								if(variable.classMethods[name]) {
									return variable;
								}
							}
							else {
								if(variable.instanceMethods[name]) {
									return variable;
								}
								else if(variable.instanceVariables[name] && variable.instanceVariables[name].type) {
									return $variable.fromReflectType(variable.instanceVariables[name].type, node);
								}
								else if(variable.instanceVariables[name]) {
									console.error(variable);
									throw new Error("Not implemented");
								}
							}
						}
						else if(variable.kind === VariableKind.Function) {
							if(data.object.kind === Kind.CallExpression) {
								return $variable.filterType(variable, name, node);
							}
							else {
								return node.getVariable("Function");
							}
						}
						else if(variable.kind === VariableKind.Variable) {
							return $variable.filterType(variable, name, node);
						}
						else {
							console.error(variable);
							throw new Error("Not implemented");
						}
					}
				}
			}
			else if(__ks_0 === Kind.NumericExpression) {
				return {
					kind: VariableKind.Variable,
					type: {
						kind: Kind.TypeReference,
						typeName: {
							kind: Kind.Identifier,
							name: "Number"
						}
					}
				};
			}
			else if(__ks_0 === Kind.TernaryConditionalExpression) {
				var a = $type.type(data.then, node);
				var b = $type.type(data.else, node);
				if(a && b && $type.same(a, b)) {
					return {
						kind: VariableKind.Variable,
						type: a
					};
				}
			}
			else if(__ks_0 === Kind.Template) {
				return {
					kind: VariableKind.Variable,
					type: {
						kind: Kind.TypeReference,
						typeName: {
							kind: Kind.Identifier,
							name: "String"
						}
					}
				};
			}
			else if(__ks_0 === Kind.TypeReference) {
				if(data.typeName) {
					return node.getVariable($types[data.typeName.name] || data.typeName.name);
				}
			}
			return null;
		},
		fromReflectType(type, node) {
			if(type === undefined || type === null) {
				throw new Error("Missing parameter 'type'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(type === "Any") {
				return null;
			}
			else if(Type.isString(type)) {
				return node.getVariable(type);
			}
			else {
				console.error(type);
				throw new Error("Not implemented");
			}
		},
		fromType(data, node) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(node === undefined || node === null) {
				throw new Error("Missing parameter 'node'");
			}
			if(data.typeName) {
				if(data.typeName.kind === Kind.Identifier) {
					var name = $types[data.typeName.name] || data.typeName.name;
					var variable = node.getVariable(name);
					if(variable) {
						return variable;
					}
					if((name = $defaultTypes[name])) {
						variable = {
							name: name,
							kind: VariableKind.Class,
							constructors: [],
							instanceVariables: {},
							classVariables: {},
							instanceMethods: {},
							classMethods: {}
						};
						if(data.typeParameters && (data.typeParameters.length === 1)) {
							variable.type = data.typeParameters[0];
						}
						return variable;
					}
				}
				else {
					var variable = $variable.fromAST(data.typeName.object, node);
					if(variable && (variable.kind === VariableKind.Variable) && variable.type && variable.type.properties) {
						var name = data.typeName.property.name;
						var __ks_0 = variable.type.properties;
						for(var __ks_1 = 0, __ks_2 = __ks_0.length, property; __ks_1 < __ks_2; ++__ks_1) {
							property = __ks_0[__ks_1];
							if(property.name.name === name) {
								property.accessPath = (variable.accessPath || variable.name.name) + ".";
								return property;
							}
						}
					}
					else {
						console.error(data.typeName);
						throw new Error("Not implemented");
					}
				}
			}
			return null;
		},
		kind(type = null) {
			if(type) {
				var __ks_0 = type.kind;
				if(__ks_0 === Kind.TypeReference) {
					if(type.typeName) {
						if(type.typeName.kind === Kind.Identifier) {
							var name = $types[type.typeName.name] || type.typeName.name;
							return $typekinds[name] || VariableKind.Variable;
						}
					}
				}
			}
			return VariableKind.Variable;
		},
		scope(config) {
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			return (config.variables === "es5") ? ("var ") : ("let ");
		},
		value(variable, data) {
			if(variable === undefined || variable === null) {
				throw new Error("Missing parameter 'variable'");
			}
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(variable.kind === VariableKind.Enum) {
				if(variable.type === "number") {
					if(data.value) {
						variable.counter = $toInt(data.value, variable.counter);
					}
					else {
						++variable.counter;
					}
					return variable.counter;
				}
				else if(variable.type === "string") {
					return $quote(data.name.name.toLowerCase());
				}
			}
			return "";
		}
	};
	class Block {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._code = [];
			this._config = null;
			this._prepared = false;
			this._renamedIndexes = {};
			this._renamedVars = {};
			this._variables = {};
		}
		__ks_init() {
			Block.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			this._indentation = 1;
			this._indent = "\t";
			this._temp = -1;
		}
		__ks_cons_1(parent) {
			if(parent === undefined || parent === null) {
				throw new Error("Missing parameter 'parent'");
			}
			this._parent = parent;
			this._indentation = parent._indentation + 1;
			this._indent = "\t".repeat(this._indentation);
			this._temp = parent.getTempCount(true);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Block.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Block.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_addVariable_0(name, definition) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(definition === undefined || definition === null) {
				throw new Error("Missing parameter 'definition'");
			}
			this._variables[name] = definition;
			return this;
		}
		addVariable() {
			if(arguments.length === 2) {
				return Block.prototype.__ks_func_addVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_block_0(reference) {
			if(reference === undefined || reference === null) {
				throw new Error("Missing parameter 'reference'");
			}
			return {
				block: this,
				reference: reference
			};
		}
		block() {
			if(arguments.length === 1) {
				return Block.prototype.__ks_func_block_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_code_0(...args) {
			for(var __ks_0 = 0, __ks_1 = args.length, arg; __ks_0 < __ks_1; ++__ks_0) {
				arg = args[__ks_0];
				__ks_Array._im_append(this._code, arg);
			}
			return this;
		}
		code() {
			return Block.prototype.__ks_func_code_0.apply(this, arguments);
		}
		__ks_func_codeVariable_0(data) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			var name = Type.vexists(this._renamedVars[data.name], data.name);
			this._code.push(name);
			return name;
		}
		codeVariable() {
			if(arguments.length === 1) {
				return Block.prototype.__ks_func_codeVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_compile_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			if(arguments.length > 2) {
				var mode = arguments[++__ks_i];
			}
			else  {
				var mode = 0;
			}
			if(arguments.length > 3) {
				var info = arguments[++__ks_i];
			}
			else  {
				var info = null;
			}
			if(!this._config) {
				this._config = config;
			}
			if(Type.isString(data)) {
				this._code.push(data);
			}
			else {
				var r = $compile(this, data, config, mode, info);
				if(r && r.node && r.close) {
					return r;
				}
			}
			return this;
		}
		compile() {
			if(arguments.length >= 2 && arguments.length <= 4) {
				return Block.prototype.__ks_func_compile_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getTempCount_0(fromChild) {
			if(fromChild === undefined || fromChild === null) {
				fromChild = true;
			}
			return this._temp;
		}
		getTempCount() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Block.prototype.__ks_func_getTempCount_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = true;
			}
			if(this._variables[name]) {
				return this._variables[name];
			}
			else if(this._parent) {
				return this._parent.getVariable(name, true);
			}
			else {
				return null;
			}
		}
		getVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Block.prototype.__ks_func_getVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_hasVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = true;
			}
			if(this._variables && this._variables[name]) {
				return true;
			}
			else if(this._parent) {
				return this._parent.hasVariable(name, true);
			}
			else {
				return false;
			}
		}
		hasVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Block.prototype.__ks_func_hasVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_indent_0() {
			++this._indentation;
			this._indent = this._indent + "\t";
			return this;
		}
		indent() {
			if(arguments.length === 0) {
				return Block.prototype.__ks_func_indent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_listNewVariables_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var variables = [];
			var __ks_0 = this._code;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, code; __ks_1 < __ks_2; ++__ks_1) {
				code = __ks_0[__ks_1];
				if(!Type.isPrimitive(code)) {
					__ks_Array._im_appendUniq(variables, code.listNewVariables(mode));
				}
			}
			this._prepared = true;
			return variables;
		}
		listNewVariables() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Block.prototype.__ks_func_listNewVariables_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newline_0() {
			this._code.push("\n" + this._indent);
			return this;
		}
		newline() {
			if(arguments.length === 0) {
				return Block.prototype.__ks_func_newline_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newBlock_0() {
			return this;
		}
		newBlock() {
			if(arguments.length === 0) {
				return Block.prototype.__ks_func_newBlock_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newControl_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var control = new Control(this, false, mode);
			this._code.push(control);
			return control;
		}
		newControl() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Block.prototype.__ks_func_newControl_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newExpression_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var stmt = new Expression(this, mode | Mode.Statement);
			this._code.push(stmt);
			return stmt;
		}
		newExpression() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Block.prototype.__ks_func_newExpression_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newFunction_0() {
			var stmt = new FunctionBlock(this);
			this._code.push(stmt);
			return stmt;
		}
		newFunction() {
			if(arguments.length === 0) {
				return Block.prototype.__ks_func_newFunction_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newTempName_0() {
			var name = "__ks_" + ++this._temp;
			while(this._variables[name]) {
				name = "__ks_" + ++this._temp;
			}
			return name;
		}
		newTempName() {
			if(arguments.length === 0) {
				return Block.prototype.__ks_func_newTempName_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_rename_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			var newName = this.newRenamedVar(name);
			if(newName !== name) {
				this._renamedVars[name] = newName;
			}
			return this;
		}
		rename() {
			if(arguments.length === 1) {
				return Block.prototype.__ks_func_rename_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var src = "";
			var str = false;
			var variables;
			var __ks_0 = this._code;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, code; __ks_1 < __ks_2; ++__ks_1) {
				code = __ks_0[__ks_1];
				if(Type.isPrimitive(code)) {
					if(!str) {
						if(src.length) {
							src += "\n";
						}
						src += this._indent;
						str = true;
					}
					src += code;
				}
				else {
					if(!this._prepared) {
						variables = code.listNewVariables();
						if(variables.length) {
							if(str) {
								src += ";\n";
								str = false;
							}
							else if(src.length) {
								src += "\n";
							}
							src += this._indent + $variable.scope(this._config) + variables.join(", ") + ";";
						}
					}
					code = code.toSource(mode);
					if(code.length) {
						if(str) {
							src += ";\n";
							str = false;
						}
						else if(src.length) {
							src += "\n";
						}
						src += code;
					}
				}
			}
			if(str) {
				src += ";";
			}
			if(src.length) {
				src += "\n";
			}
			return src;
		}
		toSource() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Block.prototype.__ks_func_toSource_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_unindent_0() {
			this._indent = "\t".repeat(--this._indentation);
			return this;
		}
		unindent() {
			if(arguments.length === 0) {
				return Block.prototype.__ks_func_unindent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Block.__ks_reflect = {
		inits: 1,
		constructors: [
			{
				access: 3,
				min: 0,
				max: 0,
				parameters: [
				]
			},
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
		instanceVariables: {
			_code: {
				access: 1,
				type: "Array"
			},
			_config: {
				access: 1
			},
			_parent: {
				access: 1
			},
			_prepared: {
				access: 1
			},
			_renamedIndexes: {
				access: 1
			},
			_renamedVars: {
				access: 1
			},
			_variables: {
				access: 1
			}
		},
		classVariables: {
		},
		instanceMethods: {
			addVariable: [
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			],
			block: [
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
			code: [
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			],
			codeVariable: [
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
			compile: [
				{
					access: 3,
					min: 2,
					max: 4,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 4
						}
					]
				}
			],
			getTempCount: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			getVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			hasVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			indent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			listNewVariables: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newline: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newBlock: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newControl: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newExpression: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newFunction: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newTempName: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			rename: [
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
			toSource: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			unindent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			]
		},
		classMethods: {
		}
	};
	class Node extends Block {
		__ks_init() {
			Block.prototype.__ks_init.call(this);
		}
		__ks_cons_0(parent) {
			if(parent === undefined || parent === null) {
				throw new Error("Missing parameter 'parent'");
			}
			Block.prototype.__ks_cons.call(this, [parent]);
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Node.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Block.prototype.__ks_cons.call(this, args);
			}
		}
		__ks_func_getRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(this._renamedVars[name]) {
				return this._renamedVars[name];
			}
			else if(this._variables[name]) {
				return name;
			}
			else {
				return this._parent.getRenamedVar(name);
			}
		}
		getRenamedVar() {
			if(arguments.length === 1) {
				return Node.prototype.__ks_func_getRenamedVar_0.apply(this, arguments);
			}
			else if(Block.prototype.getRenamedVar) {
				return Block.prototype.getRenamedVar.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_module_0() {
			return this._parent.module();
		}
		module() {
			if(arguments.length === 0) {
				return Node.prototype.__ks_func_module_0.apply(this);
			}
			else if(Block.prototype.module) {
				return Block.prototype.module.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(this._variables[name]) {
				var index = (this._renamedIndexes[name]) ? (this._renamedIndexes[name]) : (0);
				var newName = "__ks_" + name + "_" + ++index;
				while(this._variables[newName]) {
					newName = "__ks_" + name + "_" + ++index;
				}
				this._renamedIndexes[name] = index;
				return newName;
			}
			else {
				return this._parent.newRenamedVar(name);
			}
		}
		newRenamedVar() {
			if(arguments.length === 1) {
				return Node.prototype.__ks_func_newRenamedVar_0.apply(this, arguments);
			}
			else if(Block.prototype.newRenamedVar) {
				return Block.prototype.newRenamedVar.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Node.__ks_reflect = {
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
		instanceVariables: {
		},
		classVariables: {
		},
		instanceMethods: {
			getRenamedVar: [
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
			module: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newRenamedVar: [
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
			]
		},
		classMethods: {
		}
	};
	class Scope extends Block {
		__ks_init() {
			Block.prototype.__ks_init.call(this);
		}
		__ks_cons_0(parent) {
			if(parent === undefined || parent === null) {
				throw new Error("Missing parameter 'parent'");
			}
			if(Type.is(parent, Module)) {
				Block.prototype.__ks_cons.call(this, []);
				this._module = parent;
			}
			else {
				Block.prototype.__ks_cons.call(this, [parent]);
			}
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Scope.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Block.prototype.__ks_cons.call(this, args);
			}
		}
		__ks_func_getRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(this._renamedVars[name]) {
				return this._renamedVars[name];
			}
			else {
				return name;
			}
		}
		getRenamedVar() {
			if(arguments.length === 1) {
				return Scope.prototype.__ks_func_getRenamedVar_0.apply(this, arguments);
			}
			else if(Block.prototype.getRenamedVar) {
				return Block.prototype.getRenamedVar.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_module_0() {
			if(this._module) {
				return this._module;
			}
			else {
				return this._parent.module();
			}
		}
		module() {
			if(arguments.length === 0) {
				return Scope.prototype.__ks_func_module_0.apply(this);
			}
			else if(Block.prototype.module) {
				return Block.prototype.module.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(this._variables[name]) {
				var index = (this._renamedIndexes[name]) ? (this._renamedIndexes[name]) : (0);
				var newName = "__ks_" + name + "_" + ++index;
				while(this._variables[newName]) {
					newName = "__ks_" + name + "_" + ++index;
				}
				this._renamedIndexes[name] = index;
				return newName;
			}
			else {
				return name;
			}
		}
		newRenamedVar() {
			if(arguments.length === 1) {
				return Scope.prototype.__ks_func_newRenamedVar_0.apply(this, arguments);
			}
			else if(Block.prototype.newRenamedVar) {
				return Block.prototype.newRenamedVar.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Scope.__ks_reflect = {
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
		instanceVariables: {
			_module: {
				access: 1
			}
		},
		classVariables: {
		},
		instanceMethods: {
			getRenamedVar: [
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
			module: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newRenamedVar: [
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
			]
		},
		classMethods: {
		}
	};
	class Control {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._index = 0;
			this._scope = false;
			this._steps = [];
		}
		__ks_init() {
			Control.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var parent = arguments[++__ks_i];
			var scope = arguments[++__ks_i];
			if(arguments.length > 2) {
				var mode = arguments[++__ks_i];
			}
			else  {
				var mode = 0;
			}
			this._parent = parent;
			this._scope = scope;
			this._mode = mode;
			this._indentation = parent._codeIndentation || parent._indentation;
			this._indent = parent._codeIndent || parent._indent;
			this._steps.push(new Expression(this));
		}
		__ks_cons(args) {
			if(args.length >= 2 && args.length <= 3) {
				Control.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_addMode_0(mode) {
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			this._steps[this._index].addMode(mode);
			return this;
		}
		addMode() {
			if(arguments.length === 1) {
				return Control.prototype.__ks_func_addMode_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_addVariable_0(name, definition) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(definition === undefined || definition === null) {
				throw new Error("Missing parameter 'definition'");
			}
			if((this._index % 2) === 0) {
				return this._parent.addVariable(name, definition);
			}
			else {
				this._steps[this._index].addVariable(name, definition);
			}
			return this;
		}
		addVariable() {
			if(arguments.length === 2) {
				return Control.prototype.__ks_func_addVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_code_0(...args) {
			this._steps[this._index].code.apply(this._steps[this._index], args);
			return this;
		}
		code() {
			return Control.prototype.__ks_func_code_0.apply(this, arguments);
		}
		__ks_func_codeVariable_0(data) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			this._steps[this._index].codeVariable(data);
			return this;
		}
		codeVariable() {
			if(arguments.length === 1) {
				return Control.prototype.__ks_func_codeVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_compile_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			if(arguments.length > 2) {
				var mode = arguments[++__ks_i];
			}
			else  {
				var mode = 0;
			}
			if(arguments.length > 3) {
				var info = arguments[++__ks_i];
			}
			else  {
				var info = null;
			}
			if(Type.isString(data)) {
				this.code(data);
			}
			else {
				var r = $compile(this, data, config, mode, info);
				if(r && r.node && r.close) {
					return r;
				}
			}
			return this;
		}
		compile() {
			if(arguments.length >= 2 && arguments.length <= 4) {
				return Control.prototype.__ks_func_compile_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._parent.getRenamedVar(name);
		}
		getRenamedVar() {
			if(arguments.length === 1) {
				return Control.prototype.__ks_func_getRenamedVar_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getTempCount_0(fromChild) {
			if(fromChild === undefined || fromChild === null) {
				fromChild = false;
			}
			if(fromChild || ((this._index % 2) === 0)) {
				return this._parent.getTempCount();
			}
			else {
				return this._steps[this._index].getTempCount();
			}
		}
		getTempCount() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Control.prototype.__ks_func_getTempCount_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = false;
			}
			if(fromChild || ((this._index % 2) === 0)) {
				return this._parent.getVariable(name);
			}
			else {
				return this._steps[this._index].getVariable(name);
			}
		}
		getVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Control.prototype.__ks_func_getVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_hasVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = false;
			}
			if(fromChild || ((this._index % 2) === 0)) {
				return this._parent.hasVariable(name);
			}
			else {
				return this._steps[this._index].hasVariable(name);
			}
		}
		hasVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Control.prototype.__ks_func_hasVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_indent_0() {
			++this._indentation;
			this._indent = this._indent + "\t";
			this._steps[this._index].indent();
			return this;
		}
		indent() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_indent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_length_0() {
			return this._steps.length;
		}
		length() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_length_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_module_0() {
			return this._parent.module();
		}
		module() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_module_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newline_0() {
			this._steps[this._index].newline();
			return this;
		}
		newline() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_newline_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newBlock_0() {
			return this._steps[this._index].newBlock();
		}
		newBlock() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_newBlock_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newControl_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			return this._steps[this._index].newControl(mode);
		}
		newControl() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Control.prototype.__ks_func_newControl_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newExpression_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			return this._steps[this._index].newExpression(mode);
		}
		newExpression() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Control.prototype.__ks_func_newExpression_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newFunction_0() {
			return this._steps[this._index].newFunction();
		}
		newFunction() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_newFunction_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._parent.newRenamedVar(name);
		}
		newRenamedVar() {
			if(arguments.length === 1) {
				return Control.prototype.__ks_func_newRenamedVar_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newTempName_0() {
			if((this._index % 2) === 0) {
				if((this._index + 1) >= this._steps.length) {
					this._steps.push((this._scope) ? (new Scope(this)) : (new Node(this)));
				}
				return this._steps[this._index + 1].newTempName();
			}
			else {
				return this._steps[this._index].newTempName();
			}
		}
		newTempName() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_newTempName_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_rename_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if((this._index % 2) === 0) {
				if((this._index + 1) >= this._steps.length) {
					this._steps.push((this._scope) ? (new Scope(this)) : (new Node(this)));
				}
				this._steps[this._index + 1].rename(name);
			}
			else {
				this._steps[this._index].rename(name);
			}
			return this;
		}
		rename() {
			if(arguments.length === 1) {
				return Control.prototype.__ks_func_rename_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_step_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			if((this._index + 1) >= this._steps.length) {
				if((this._steps.length % 2) === 0) {
					this._steps.push(new Expression(this, mode));
				}
				else if(this._scope) {
					this._steps.push(new Scope(this));
				}
				else {
					this._steps.push(new Node(this));
				}
			}
			++this._index;
			return this;
		}
		step() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Control.prototype.__ks_func_step_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_listNewVariables_0() {
			var variables = [];
			if(this._mode & Mode.PrepareAll) {
				var __ks_0 = this._steps;
				for(var __ks_1 = 0, __ks_2 = __ks_0.length, step; __ks_1 < __ks_2; ++__ks_1) {
					step = __ks_0[__ks_1];
					__ks_Array._im_appendUniq(variables, step.listNewVariables(Mode.PrepareAll));
				}
			}
			else if(!(this._mode & Mode.PrepareNone)) {
				for(var s = 0, __ks_0 = this._steps.length; s < __ks_0; s += 2) {
					__ks_Array._im_appendUniq(variables, this._steps[s].listNewVariables(Mode.PrepareAll));
				}
			}
			return variables;
		}
		listNewVariables() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_listNewVariables_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_parameter_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			if(arguments.length > 2) {
				var type = arguments[++__ks_i];
			}
			else  {
				var type = null;
			}
			this.compile(data, config, Mode.Key);
			if((this._index % 2) === 0) {
				if((this._index + 1) >= this._steps.length) {
					this._steps.push((this._scope) ? (new Scope(this)) : (new Node(this)));
				}
				if(type) {
					$variable.define(this._steps[this._index + 1], data.name || data, $variable.kind(type), type);
				}
				else {
					$variable.define(this._steps[this._index + 1], data.name || data, $variable.kind(data.type), data.type);
				}
			}
			else {
				if(type) {
					$variable.define(this._steps[this._index], data.name || data, $variable.kind(type), type);
				}
				else {
					$variable.define(this._steps[this._index], data.name || data, $variable.kind(data.type), data.type);
				}
			}
			return this;
		}
		parameter() {
			if(arguments.length >= 2 && arguments.length <= 3) {
				return Control.prototype.__ks_func_parameter_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var src = "";
			mode = (this._mode & Mode.PrepareAll) ? (Mode.PrepareAll) : (0);
			for(var s = 0, __ks_0 = this._steps.length; s < __ks_0; s += 2) {
				if((s + 1) === this._steps.length) {
					if(this._steps[s].length() === 0) {
					}
					else if(s && !(this._steps[s]._mode & Mode.NoLine)) {
						src += "\n";
						src += this._steps[s].toSource(Mode.PrepareAll);
					}
					else {
						src += this._steps[s].toSource(Mode.PrepareAll | Mode.NoIndent);
					}
				}
				else {
					if(s) {
						src += "\n";
					}
					src += this._steps[s].toSource(Mode.PrepareAll);
					src += " {\n";
					src += this._steps[s + 1].toSource(mode);
					src += "\t".repeat(this._steps[s + 1]._indentation - 1) + "}";
				}
			}
			return src;
		}
		toSource() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Control.prototype.__ks_func_toSource_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_unindent_0() {
			this._indent = "\t".repeat(--this._indentation);
			this._steps[this._index].unindent();
			return this;
		}
		unindent() {
			if(arguments.length === 0) {
				return Control.prototype.__ks_func_unindent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_use_0(...args) {
			return this._steps[this._index].use.apply(this._steps[this._index], args);
		}
		use() {
			return Control.prototype.__ks_func_use_0.apply(this, arguments);
		}
	}
	Control.__ks_reflect = {
		inits: 1,
		constructors: [
			{
				access: 3,
				min: 2,
				max: 3,
				parameters: [
					{
						type: "Any",
						min: 2,
						max: 3
					}
				]
			}
		],
		instanceVariables: {
			_index: {
				access: 1
			},
			_mode: {
				access: 1
			},
			_parent: {
				access: 1
			},
			_scope: {
				access: 1
			},
			_steps: {
				access: 1
			}
		},
		classVariables: {
		},
		instanceMethods: {
			addMode: [
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
			addVariable: [
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			],
			code: [
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			],
			codeVariable: [
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
			compile: [
				{
					access: 3,
					min: 2,
					max: 4,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 4
						}
					]
				}
			],
			getRenamedVar: [
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
			getTempCount: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			getVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			hasVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			indent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			length: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			module: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newline: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newBlock: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newControl: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newExpression: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newFunction: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newRenamedVar: [
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
			newTempName: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			rename: [
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
			step: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			listNewVariables: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			parameter: [
				{
					access: 3,
					min: 2,
					max: 3,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 3
						}
					]
				}
			],
			toSource: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			unindent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			use: [
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			]
		},
		classMethods: {
		}
	};
	class Expression {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._assignment = false;
			this._config = null;
			this._code = [];
			this._prepared = false;
			this._usages = [];
			this._reference = "";
			this._variables = [];
		}
		__ks_init() {
			Expression.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var parent = arguments[++__ks_i];
			if(arguments.length > 1) {
				var mode = arguments[++__ks_i];
			}
			else  {
				var mode = 0;
			}
			this._parent = parent;
			this._mode = mode;
			this._indentation = parent._indentation;
			this._indent = parent._indent;
			this._codeIndentation = parent._indentation;
			this._codeIndent = parent._indent;
		}
		__ks_cons(args) {
			if(args.length >= 1 && args.length <= 2) {
				Expression.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_addMode_0(mode) {
			if(mode === undefined || mode === null) {
				throw new Error("Missing parameter 'mode'");
			}
			this._mode |= mode;
			return this;
		}
		addMode() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_addMode_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_addVariable_0(name, definition) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(definition === undefined || definition === null) {
				throw new Error("Missing parameter 'definition'");
			}
			this._parent.addVariable(name, definition);
			return this;
		}
		addVariable() {
			if(arguments.length === 2) {
				return Expression.prototype.__ks_func_addVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_assignment_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			if(arguments.length > 1) {
				var variable = arguments[++__ks_i];
			}
			else  {
				var variable = false;
			}
			if((data.left.kind === Kind.Identifier) && !this.hasVariable(data.left.name)) {
				if(variable || this._assignment) {
					this._variables.push(data.left.name);
				}
				else {
					this._assignment = data.left.name;
				}
				$variable.define(this, data.left, $variable.kind(data.right.type), data.right.type);
			}
			return this;
		}
		assignment() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Expression.prototype.__ks_func_assignment_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_block_0(reference = null) {
			return this._parent.block((reference) ? (this._reference + reference) : (this._reference));
		}
		block() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Expression.prototype.__ks_func_block_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_code_0(...args) {
			for(var __ks_0 = 0, __ks_1 = args.length, arg; __ks_0 < __ks_1; ++__ks_0) {
				arg = args[__ks_0];
				__ks_Array._im_append(this._code, arg);
			}
			return this;
		}
		code() {
			return Expression.prototype.__ks_func_code_0.apply(this, arguments);
		}
		__ks_func_codeVariable_0(data) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			var name = this.getRenamedVar(data.name);
			this._code.push(name);
			return this;
		}
		codeVariable() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_codeVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_compile_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			if(arguments.length > 2) {
				var mode = arguments[++__ks_i];
			}
			else  {
				var mode = 0;
			}
			if(arguments.length > 3) {
				var info = arguments[++__ks_i];
			}
			else  {
				var info = null;
			}
			if(!this._config) {
				this._config = config;
			}
			if(Type.isString(data)) {
				this._code.push(data);
			}
			else {
				$compile(this, data, config, mode, info);
			}
			return this;
		}
		compile() {
			if(arguments.length >= 2 && arguments.length <= 4) {
				return Expression.prototype.__ks_func_compile_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._parent.getRenamedVar(name);
		}
		getRenamedVar() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_getRenamedVar_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getTempCount_0(fromChild) {
			if(fromChild === undefined || fromChild === null) {
				fromChild = true;
			}
			return this._parent.getTempCount(fromChild);
		}
		getTempCount() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Expression.prototype.__ks_func_getTempCount_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = true;
			}
			return this._parent.getVariable(name, fromChild);
		}
		getVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Expression.prototype.__ks_func_getVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_hasVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = true;
			}
			return this._parent.hasVariable(name, fromChild);
		}
		hasVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Expression.prototype.__ks_func_hasVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_indent_0() {
			if(this._code.length) {
				++this._codeIndentation;
				this._codeIndent = this._codeIndent + "\t";
			}
			else {
				++this._indentation;
				this._indent = this._indent + "\t";
			}
			return this;
		}
		indent() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_indent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_length_0() {
			return this._code.length;
		}
		length() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_length_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_module_0() {
			return this._parent.module();
		}
		module() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_module_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newline_0() {
			this._code.push("\n" + this._codeIndent);
			return this;
		}
		newline() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_newline_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newControl_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var control = new Control(this, false, mode);
			this._code.push(control);
			return control;
		}
		newControl() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Expression.prototype.__ks_func_newControl_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newExpression_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			return this;
		}
		newExpression() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Expression.prototype.__ks_func_newExpression_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newFunction_0() {
			var code = new FunctionBlock(this);
			this._code.push(code);
			return code;
		}
		newFunction() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_newFunction_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newObject_0() {
			var code = new ObjectBlock(this);
			this._code.push(code);
			return code;
		}
		newObject() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_newObject_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._parent.newRenamedVar(name);
		}
		newRenamedVar() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_newRenamedVar_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newTempName_0() {
			var name = this._parent.newTempName();
			__ks_Array._im_pushUniq(this._variables, name);
			return name;
		}
		newTempName() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_newTempName_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_listNewVariables_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			this._prepared = true;
			if((mode & Mode.PrepareAll) && this._assignment) {
				return [this._assignment].concat(this._variables);
			}
			else {
				return this._variables;
			}
		}
		listNewVariables() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Expression.prototype.__ks_func_listNewVariables_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_parameter_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			if(arguments.length > 2) {
				var type = arguments[++__ks_i];
			}
			else  {
				var type = null;
			}
			$compile(this, data, config, Mode.Key);
			if(data.name) {
				$variable.define(this._parent, data.name, $variable.kind(data.type), data.type);
			}
			else {
				$variable.define(this._parent, data, $variable.kind(type), type);
			}
			return this;
		}
		parameter() {
			if(arguments.length >= 2 && arguments.length <= 3) {
				return Expression.prototype.__ks_func_parameter_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_reference_0(reference) {
			if(reference === undefined || reference === null) {
				throw new Error("Missing parameter 'reference'");
			}
			this._reference = reference;
			return this;
		}
		reference() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_reference_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_rename_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			this._parent.rename(name);
			return this;
		}
		rename() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_rename_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var __ks_0 = this._usages;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, variable; __ks_1 < __ks_2; ++__ks_1) {
				variable = __ks_0[__ks_1];
				if(!this._parent.hasVariable(variable.name)) {
					throw new Error("Undefined variable '" + variable.name + "' at line " + variable.start.line);
				}
			}
			var src = "";
			if(!((this._mode & Mode.NoIndent) || (mode & Mode.NoIndent))) {
				src += this._indent;
			}
			if(this._prepared) {
				if(!(mode & Mode.PrepareAll) && this._assignment) {
					src += $variable.scope(this._config);
				}
			}
			else {
				if(this._assignment) {
					src += $variable.scope(this._config);
				}
				if(this._variables.length) {
					src = this._indent + $variable.scope(this._config) + this._variables.join(", ") + ";\n" + src;
				}
			}
			var __ks_1 = this._code;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, code; __ks_2 < __ks_3; ++__ks_2) {
				code = __ks_1[__ks_2];
				if(Type.isPrimitive(code)) {
					src += code;
				}
				else {
					src += code.toSource();
				}
			}
			if(this._mode & Mode.Statement) {
				return src + ";";
			}
			else {
				return src;
			}
		}
		toSource() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Expression.prototype.__ks_func_toSource_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_unindent_0() {
			if(this._code.length) {
				this._codeIndent = "\t".repeat(--this._codeIndentation);
			}
			else {
				this._indent = "\t".repeat(--this._indentation);
			}
			return this;
		}
		unindent() {
			if(arguments.length === 0) {
				return Expression.prototype.__ks_func_unindent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_use_0(data) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(data.kind === Kind.Identifier) {
				this._usages.push({
					name: data.name,
					start: data.start
				});
			}
			return this;
		}
		use() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_use_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_write_0(data) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(Type.isObject(data)) {
				this.code("{").indent();
				var nf = false;
				for(var name in data) {
					if(nf) {
						this.code(",");
					}
					else {
						nf = true;
					}
					this.newline().code($quote(name) + ": ").write(data[name]);
				}
				this.unindent().newline().code("}");
			}
			else {
				this.code(Type.toSource(data));
			}
			return this;
		}
		write() {
			if(arguments.length === 1) {
				return Expression.prototype.__ks_func_write_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Expression.__ks_reflect = {
		inits: 1,
		constructors: [
			{
				access: 3,
				min: 1,
				max: 2,
				parameters: [
					{
						type: "Any",
						min: 1,
						max: 2
					}
				]
			}
		],
		instanceVariables: {
			_assignment: {
				access: 1
			},
			_config: {
				access: 1
			},
			_code: {
				access: 1,
				type: "Array"
			},
			_mode: {
				access: 1
			},
			_parent: {
				access: 1
			},
			_prepared: {
				access: 1
			},
			_usages: {
				access: 1
			},
			_reference: {
				access: 1
			},
			_variables: {
				access: 1,
				type: "Array"
			}
		},
		classVariables: {
		},
		instanceMethods: {
			addMode: [
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
			addVariable: [
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			],
			assignment: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			block: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			code: [
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			],
			codeVariable: [
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
			compile: [
				{
					access: 3,
					min: 2,
					max: 4,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 4
						}
					]
				}
			],
			getRenamedVar: [
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
			getTempCount: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			getVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			hasVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			indent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			length: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			module: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newline: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newControl: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newExpression: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			newFunction: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newObject: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newRenamedVar: [
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
			newTempName: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			listNewVariables: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			parameter: [
				{
					access: 3,
					min: 2,
					max: 3,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 3
						}
					]
				}
			],
			reference: [
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
			rename: [
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
			toSource: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			unindent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			use: [
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
			write: [
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
			]
		},
		classMethods: {
		}
	};
	class FunctionBlock {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._unprepared = true;
		}
		__ks_init() {
			FunctionBlock.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(parent) {
			if(parent === undefined || parent === null) {
				throw new Error("Missing parameter 'parent'");
			}
			this._parent = parent;
			this._ctrl = new Control(parent, true, Mode.PrepareNone);
		}
		__ks_cons(args) {
			if(args.length === 1) {
				FunctionBlock.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_listNewVariables_0() {
			return [];
		}
		listNewVariables() {
			if(arguments.length === 0) {
				return FunctionBlock.prototype.__ks_func_listNewVariables_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_operation_0(operation) {
			if(operation === undefined || operation === null) {
				throw new Error("Missing parameter 'operation'");
			}
			this._operation = operation;
			return this;
		}
		operation() {
			if(arguments.length === 1) {
				return FunctionBlock.prototype.__ks_func_operation_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			if(this._unprepared) {
				this._operation(this._ctrl);
				this._unprepared = false;
			}
			return this._ctrl.toSource(mode);
		}
		toSource() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return FunctionBlock.prototype.__ks_func_toSource_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	FunctionBlock.__ks_reflect = {
		inits: 1,
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
		instanceVariables: {
			_operation: {
				access: 1
			},
			_parent: {
				access: 1
			},
			_unprepared: {
				access: 1
			}
		},
		classVariables: {
		},
		instanceMethods: {
			listNewVariables: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			operation: [
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
			toSource: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {
		}
	};
	class ObjectBlock {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._code = [];
			this._config = null;
		}
		__ks_init() {
			ObjectBlock.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(parent) {
			if(parent === undefined || parent === null) {
				throw new Error("Missing parameter 'parent'");
			}
			this._parent = parent;
			this._closingIndent = parent._codeIndent;
			this._indentation = parent._codeIndentation + 1;
			this._indent = "\t".repeat(this._indentation);
		}
		__ks_cons(args) {
			if(args.length === 1) {
				ObjectBlock.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_block_0(reference = null) {
			return this._parent.block(reference);
		}
		block() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return ObjectBlock.prototype.__ks_func_block_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_compile_0() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var data = arguments[++__ks_i];
			var config = arguments[++__ks_i];
			if(arguments.length > 2) {
				var mode = arguments[++__ks_i];
			}
			else  {
				var mode = 0;
			}
			if(arguments.length > 3) {
				var info = arguments[++__ks_i];
			}
			else  {
				var info = null;
			}
			if(!this._config) {
				this._config = config;
			}
			if(Type.isString(data)) {
				this._code.push(data);
			}
			else {
				$compile(this, data, config, mode, info);
			}
			return this;
		}
		compile() {
			if(arguments.length >= 2 && arguments.length <= 4) {
				return ObjectBlock.prototype.__ks_func_compile_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getRenamedVar_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._parent.getRenamedVar(name);
		}
		getRenamedVar() {
			if(arguments.length === 1) {
				return ObjectBlock.prototype.__ks_func_getRenamedVar_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getTempCount_0(fromChild) {
			if(fromChild === undefined || fromChild === null) {
				fromChild = true;
			}
			return this._parent.getTempCount(fromChild);
		}
		getTempCount() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return ObjectBlock.prototype.__ks_func_getTempCount_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_getVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = true;
			}
			return this._parent.getVariable(name, fromChild);
		}
		getVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return ObjectBlock.prototype.__ks_func_getVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_hasVariable_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var fromChild = arguments[++__ks_i];
			}
			else  {
				var fromChild = true;
			}
			return this._parent.hasVariable(name, fromChild);
		}
		hasVariable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return ObjectBlock.prototype.__ks_func_hasVariable_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_listNewVariables_0() {
			return [];
		}
		listNewVariables() {
			if(arguments.length === 0) {
				return ObjectBlock.prototype.__ks_func_listNewVariables_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_newExpression_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			var code = new Expression(this, mode);
			this._code.push(code);
			return code;
		}
		newExpression() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return ObjectBlock.prototype.__ks_func_newExpression_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0(mode) {
			if(mode === undefined || mode === null) {
				mode = 0;
			}
			if(this._code.length) {
				var src = "{";
				var __ks_0 = this._code;
				for(var index = 0, __ks_1 = __ks_0.length, code; index < __ks_1; ++index) {
					code = __ks_0[index];
					if(index) {
						src += ",";
					}
					src += "\n" + code.toSource();
				}
				return src + "\n" + this._closingIndent + "}";
			}
			else {
				return "{}";
			}
		}
		toSource() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return ObjectBlock.prototype.__ks_func_toSource_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	ObjectBlock.__ks_reflect = {
		inits: 1,
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
		instanceVariables: {
			_code: {
				access: 1,
				type: "Array"
			},
			_config: {
				access: 1
			},
			_parent: {
				access: 1
			}
		},
		classVariables: {
		},
		instanceMethods: {
			block: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			compile: [
				{
					access: 3,
					min: 2,
					max: 4,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 4
						}
					]
				}
			],
			getRenamedVar: [
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
			getTempCount: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			getVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			hasVariable: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			listNewVariables: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			newExpression: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			toSource: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {
		}
	};
	class Module {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._binary = false;
			this._body = new Scope(this);
			this._exportSource = [];
			this._exportMeta = {};
			this._imports = {};
			this._references = {};
			this._requirements = {};
		}
		__ks_init() {
			Module.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(compiler) {
			if(compiler === undefined || compiler === null) {
				throw new Error("Missing parameter 'compiler'");
			}
			this._compiler = compiler;
			if(this._compiler._options.output) {
				this._output = path.dirname(this._compiler._options.output);
				if(Type.isArray(this._compiler._options.rewire)) {
					this._rewire = this._compiler._options.rewire;
				}
				else {
					this._rewire = [];
				}
			}
			else {
				this._output = null;
			}
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Module.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_addReference_0(key, code) {
			if(key === undefined || key === null) {
				throw new Error("Missing parameter 'key'");
			}
			if(code === undefined || code === null) {
				throw new Error("Missing parameter 'code'");
			}
			if(this._references[key]) {
				this._references[key].push(code);
			}
			else {
				this._references[key] = [code];
			}
			return this;
		}
		addReference() {
			if(arguments.length === 2) {
				return Module.prototype.__ks_func_addReference_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_do_0(data, config) {
			if(data === undefined || data === null) {
				throw new Error("Missing parameter 'data'");
			}
			if(config === undefined || config === null) {
				throw new Error("Missing parameter 'config'");
			}
			var __ks_0 = data.attributes;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, attr; __ks_1 < __ks_2; ++__ks_1) {
				attr = __ks_0[__ks_1];
				if((attr.declaration.kind === Kind.Identifier) && (attr.declaration.name === "bin")) {
					this._binary = true;
					this._body.unindent();
				}
				else if((attr.declaration.kind === Kind.AttributeExpression) && (attr.declaration.name.name === "cfg")) {
					var __ks_3 = attr.declaration.arguments;
					for(var __ks_4 = 0, __ks_5 = __ks_3.length, arg; __ks_4 < __ks_5; ++__ks_4) {
						arg = __ks_3[__ks_4];
						if(arg.kind === Kind.AttributeOperator) {
							config[arg.name.name] = arg.value.value;
						}
					}
				}
			}
			var __ks_1 = data.body;
			for(var __ks_2 = 0, __ks_3 = __ks_1.length, value; __ks_2 < __ks_3; ++__ks_2) {
				value = __ks_1[__ks_2];
				this._body.compile(value, config);
			}
			return this;
		}
		do() {
			if(arguments.length === 2) {
				return Module.prototype.__ks_func_do_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_export_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 1) {
				var alias = arguments[++__ks_i];
			}
			else  {
				var alias = false;
			}
			if(this._binary) {
				throw new Error("Binary file can't export");
			}
			var variable = this._body.getVariable(name.name);
			if(!(variable)) {
				throw new Error("Undefined variable " + name.name);
			}
			if(variable.kind !== VariableKind.TypeAlias) {
				if(alias) {
					this._exportSource.push(alias.name + ": " + name.name);
				}
				else {
					this._exportSource.push(name.name + ": " + name.name);
				}
				if((variable.kind === VariableKind.Class) && variable.final) {
					if(alias) {
						this._exportSource.push("__ks_" + alias.name + ": " + variable.final.name);
					}
					else {
						this._exportSource.push("__ks_" + name.name + ": " + variable.final.name);
					}
				}
			}
			if(alias) {
				this._exportMeta[alias.name] = variable;
			}
			else {
				this._exportMeta[name.name] = variable;
			}
			return this;
		}
		export() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Module.prototype.__ks_func_export_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_import_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			this._imports[name] = true;
		}
		import() {
			if(arguments.length === 1) {
				return Module.prototype.__ks_func_import_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_listReferences_0(key) {
			if(key === undefined || key === null) {
				throw new Error("Missing parameter 'key'");
			}
			if(this._references[key]) {
				var references = this._references[key];
				this._references[key] = null;
				return references;
			}
			else {
				return null;
			}
		}
		listReferences() {
			if(arguments.length === 1) {
				return Module.prototype.__ks_func_listReferences_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_parent_0() {
			return this._compiler.parent();
		}
		parent() {
			if(arguments.length === 0) {
				return Module.prototype.__ks_func_parent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_path_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			if(arguments.length > 1) {
				var x = arguments[++__ks_i];
			}
			else  {
				var x = null;
			}
			var name = arguments[++__ks_i];
			if(!x || !this._output) {
				return name;
			}
			var output = null;
			var __ks_0 = this._rewire;
			for(var __ks_1 = 0, __ks_2 = __ks_0.length, rewire; __ks_1 < __ks_2; ++__ks_1) {
				rewire = __ks_0[__ks_1];
				if(rewire.input === x) {
					output = path.relative(this._output, rewire.output);
					break;
				}
			}
			if(!output) {
				output = path.relative(this._output, x);
			}
			if(output[0] !== ".") {
				output = "./" + output;
			}
			return output;
		}
		path() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Module.prototype.__ks_func_path_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_require_0(name, kind) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(kind === undefined || kind === null) {
				throw new Error("Missing parameter 'kind'");
			}
			if(this._binary) {
				throw new Error("Binary file can't require");
			}
			if(kind === VariableKind.Class) {
				this._requirements[name] = {
					class: true
				};
			}
			else {
				this._requirements[name] = {};
			}
		}
		require() {
			if(arguments.length === 2) {
				return Module.prototype.__ks_func_require_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toMetadata_0() {
			var data = {
				requirements: this._requirements,
				exports: {}
			};
			var d;
			var __ks_0 = this._exportMeta;
			for(var name in __ks_0) {
				var variable = __ks_0[name];
				d = {};
				for(var n in variable) {
					if(n === "name") {
						d[n] = variable[n].name || variable[n];
					}
					else if(!(n === "accessPath")) {
						d[n] = variable[n];
					}
				}
				data.exports[name] = d;
			}
			return data;
		}
		toMetadata() {
			if(arguments.length === 0) {
				return Module.prototype.__ks_func_toMetadata_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0() {
			if(this._binary) {
				return this._body.toSource().slice(0, -1);
			}
			else {
				if(!(this._requirements.Class || this._requirements.Type) && !(this._imports.Class && this._imports.Type)) {
					this._requirements.Array = {
						class: true
					};
					this._requirements.Class = {};
					this._requirements.Function = {
						class: true
					};
					this._requirements.Object = {
						class: true
					};
					this._requirements.Type = {};
				}
				var source = "module.exports = function(";
				var nf = false;
				var __ks_0 = this._requirements;
				for(var name in __ks_0) {
					if(nf) {
						source += ", ";
					}
					else {
						nf = true;
					}
					source += name;
					if(this._requirements[name].class) {
						source += ", __ks_" + name;
					}
				}
				source += ") {\n";
				source += this._body.toSource();
				if(this._exportSource.length) {
					source += "\treturn {";
					nf = false;
					var __ks_1 = this._exportSource;
					for(var __ks_2 = 0, __ks_3 = __ks_1.length, src; __ks_2 < __ks_3; ++__ks_2) {
						src = __ks_1[__ks_2];
						if(nf) {
							source += ",";
						}
						else {
							nf = true;
						}
						source += "\n\t\t" + src;
					}
					source += "\n\t};\n";
				}
				source += "}";
				return source;
			}
		}
		toSource() {
			if(arguments.length === 0) {
				return Module.prototype.__ks_func_toSource_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Module.__ks_reflect = {
		inits: 1,
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
		instanceVariables: {
			_binary: {
				access: 1,
				type: "Boolean"
			},
			_body: {
				access: 1,
				type: Block
			},
			_compiler: {
				access: 1,
				type: "#Compiler"
			},
			_exportSource: {
				access: 1
			},
			_exportMeta: {
				access: 1
			},
			_imports: {
				access: 1
			},
			_references: {
				access: 1
			},
			_requirements: {
				access: 1
			}
		},
		classVariables: {
		},
		instanceMethods: {
			addReference: [
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			],
			do: [
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			],
			export: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			import: [
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
			listReferences: [
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
			parent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			path: [
				{
					access: 3,
					min: 1,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 2
						}
					]
				}
			],
			require: [
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			],
			toMetadata: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			toSource: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			]
		},
		classMethods: {
		}
	};
	class Compiler {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			var __ks_i = -1;
			var file = arguments[++__ks_i];
			if(arguments.length > 1) {
				var options = arguments[++__ks_i];
			}
			else  {
				var options = null;
			}
			this._file = file;
			this._options = __ks_Object._cm_append({
				context: "node6",
				config: {
					parameters: "kaoscript",
					variables: "es6"
				}
			}, options);
			this._module = new Module(this);
		}
		__ks_cons(args) {
			if(args.length >= 1 && args.length <= 2) {
				Compiler.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_compile_0(data = null) {
			data = data || fs.readFile(this._file);
			this._sha256 = fs.sha256(data);
			this._module.do(parse(data), this._options.config);
			return this;
		}
		compile() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Compiler.prototype.__ks_func_compile_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_parent_0() {
			return path.dirname(this._file);
		}
		parent() {
			if(arguments.length === 0) {
				return Compiler.prototype.__ks_func_parent_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toMetadata_0() {
			return this._module.toMetadata();
		}
		toMetadata() {
			if(arguments.length === 0) {
				return Compiler.prototype.__ks_func_toMetadata_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_toSource_0() {
			return this._module.toSource();
		}
		toSource() {
			if(arguments.length === 0) {
				return Compiler.prototype.__ks_func_toSource_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_writeFiles_0() {
			fs.writeFile(this._file + $extensions.binary, this._module.toSource());
			if(!this._module._binary) {
				var metadata = this._module.toMetadata();
				fs.writeFile(this._file + $extensions.metadata, JSON.stringify(metadata));
			}
			fs.writeFile(this._file + $extensions.hash, this._sha256);
		}
		writeFiles() {
			if(arguments.length === 0) {
				return Compiler.prototype.__ks_func_writeFiles_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_writeOutput_0() {
			if(!this._options.output) {
				throw new Error("Undefined option: output");
			}
			fs.writeFile(this._options.output, this._module.toSource());
			return this;
		}
		writeOutput() {
			if(arguments.length === 0) {
				return Compiler.prototype.__ks_func_writeOutput_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Compiler.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 1,
				max: 2,
				parameters: [
					{
						type: "Any",
						min: 1,
						max: 2
					}
				]
			}
		],
		instanceVariables: {
			_file: {
				access: 1,
				type: "String"
			},
			_module: {
				access: 1,
				type: Module
			}
		},
		classVariables: {
		},
		instanceMethods: {
			compile: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 0,
							max: 1
						}
					]
				}
			],
			parent: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			toMetadata: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			toSource: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			writeFiles: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			],
			writeOutput: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			]
		},
		classMethods: {
		}
	};
	Module.__ks_reflect.instanceVariables._compiler.type = Compiler;
	function compileFile() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		var __ks_i = -1;
		var file = arguments[++__ks_i];
		if(arguments.length > 1) {
			var options = arguments[++__ks_i];
		}
		else  {
			var options = null;
		}
		var compiler = new Compiler(file, options);
		return compiler.compile().toSource();
	}
	return {
		Compiler: Compiler,
		compileFile: compileFile,
		extensions: $extensions
	};
}