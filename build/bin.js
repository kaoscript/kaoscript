// Generated by kaoscript 0.5.0
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var Compiler = require("./compiler.js")().Compiler;
	var metadata = require("../package.json");
	var Module = require("module");
	var path = require("path");
	var program = require("commander");
	var vm = require("vm");
	function rewire(option) {
		if(option === undefined || option === null) {
			throw new Error("Missing parameter 'option'");
		}
		var files = [];
		var __ks_0 = option.split(",");
		for(var __ks_1 = 0, __ks_2 = __ks_0.length, item; __ks_1 < __ks_2; ++__ks_1) {
			item = __ks_0[__ks_1];
			item = item.split("=");
			files.push({
				input: item[0],
				output: item[1]
			});
		}
		return files;
	}
	program.version(metadata.version).usage("[options] <file>").option("-c, --compile", "compile to JavaScript and save as .js files").option("    --no-header", "suppress the \"Generated by\" header").option("-o, --output <path>", "set the output directory for compiled JavaScript").option("-p, --print", "print out the compiled JavaScript").option("    --no-register", "suppress \"require(kaoscript/register)\"").option("-r, --rewire <src-path=gen-path,...>", "rewire the references to source files to generated files", rewire).option("-t, --target <engine>", "set the engine/runtime/browser to compile for").parse(process.argv);
	if(program.args.length === 0) {
		program.outputHelp();
		process.exit(1);
	}
	var file = path.join(process.cwd(), program.args[0]);
	var options = {
		register: program.register,
		config: {
			header: program.header
		}
	};
	if(Type.isValue(program.rewire)) {
		options.rewire = [];
		for(var __ks_0 = 0, __ks_1 = program.rewire.length, item; __ks_0 < __ks_1; ++__ks_0) {
			item = program.rewire[__ks_0];
			options.rewire.push({
				input: path.join(process.cwd(), item.input),
				output: path.join(process.cwd(), item.output)
			});
		}
	}
	if(Type.isValue(program.target)) {
		options.target = program.target;
	}
	if(program.compile) {
		options.output = path.join(process.cwd(), Type.isValue(program.output) ? program.output : "");
		var compiler = new Compiler(file, options);
		compiler.compile();
		if(program.print) {
			console.log(compiler.toSource());
		}
		compiler.writeOutput();
	}
	else if(program.print) {
		var compiler = new Compiler(file, options);
		compiler.compile();
		console.log(compiler.toSource());
	}
	else {
		var compiler = new Compiler(file, options);
		compiler.compile();
		var sandbox = {};
		for(var key in global) {
			sandbox[key] = global[key];
		}
		var _module = sandbox.module = new Module("eval");
		var _require = sandbox.require = function(path) {
			if(path === undefined || path === null) {
				throw new Error("Missing parameter 'path'");
			}
			return Module._load(path, _module, true);
		};
		_module.filename = sandbox.__filename;
		var __ks_0 = Object.getOwnPropertyNames(require);
		for(var __ks_1 = 0, __ks_2 = __ks_0.length, r; __ks_1 < __ks_2; ++__ks_1) {
			r = __ks_0[__ks_1];
			if((r !== "paths") && (r !== "arguments") && (r !== "caller")) {
				_require[r] = require[r];
			}
		}
		_require.paths = _module.paths = Module._nodeModulePaths(process.cwd()).concat(process.cwd());
		_require.resolve = function(request) {
			if(request === undefined || request === null) {
				throw new Error("Missing parameter 'request'");
			}
			return Module._resolveFilename(request, _module);
		};
		vm.runInNewContext(compiler.toSource(), sandbox, file);
	}
}