func toArray(x) => x:>(Array)
func toBoolean(x) => x:>(Boolean)
func toClass(x) => x:>(Class)
func toDictionary(x) => x:>(Object)
func toEnum(x) => x:>(Enum)
func toFunction(x) => x:>(Function)
func toNamespace(x) => x:>(Namespace)
func toNumber(x) => x:>(Number)
func toObject(x) => x:>(Object)
func toPrimitive(x) => x:>(Primitive)
func toRegExp(x) => x:>(RegExp)
func toString(x) => x:>(String)
func toStruct(x) => x:>(Struct)

class Foobar {
}

func toClassInstance(x) => x:>(Foobar)

enum Quxbaz {
}

func toEnumInstance(x) => x:>(Quxbaz)

struct Corge {
}

func toStructInstance(x) => x:>(Corge)