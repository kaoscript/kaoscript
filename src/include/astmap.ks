var $assignmentOperators = {
	`\(AssignmentOperatorKind.Addition)`			: AssignmentOperatorAddition
	`\(AssignmentOperatorKind.And)`					: AssignmentOperatorAnd
	`\(AssignmentOperatorKind.Division)`			: AssignmentOperatorDivision
	`\(AssignmentOperatorKind.Empty)`				: AssignmentOperatorEmpty
	`\(AssignmentOperatorKind.EmptyCoalescing)`		: AssignmentOperatorEmptyCoalescing
	`\(AssignmentOperatorKind.Equals)`				: AssignmentOperatorEquals
	`\(AssignmentOperatorKind.Existential)`			: AssignmentOperatorExistential
	`\(AssignmentOperatorKind.LeftShift)`			: AssignmentOperatorLeftShift
	`\(AssignmentOperatorKind.Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperatorKind.Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperatorKind.NonEmpty)`			: AssignmentOperatorNonEmpty
	`\(AssignmentOperatorKind.NonExistential)`		: AssignmentOperatorNonExistential
	`\(AssignmentOperatorKind.NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperatorKind.Or)`					: AssignmentOperatorOr
	`\(AssignmentOperatorKind.Quotient)`			: AssignmentOperatorQuotient
	`\(AssignmentOperatorKind.Return)`				: AssignmentOperatorReturn
	`\(AssignmentOperatorKind.RightShift)`			: AssignmentOperatorRightShift
	`\(AssignmentOperatorKind.Subtraction)`			: AssignmentOperatorSubtraction
	`\(AssignmentOperatorKind.Xor)`					: AssignmentOperatorXor
}

var $binaryOperators = {
	`\(BinaryOperatorKind.Addition)`			: BinaryOperatorAddition
	`\(BinaryOperatorKind.And)`					: BinaryOperatorAnd
	`\(BinaryOperatorKind.BackwardPipeline)`	: BinaryOperatorBackwardPipeline
	`\(BinaryOperatorKind.Division)`			: BinaryOperatorDivision
	`\(BinaryOperatorKind.EmptyCoalescing)`		: BinaryOperatorEmptyCoalescing
	`\(BinaryOperatorKind.ForwardPipeline)`		: BinaryOperatorForwardPipeline
	`\(BinaryOperatorKind.Imply)`				: BinaryOperatorImply
	`\(BinaryOperatorKind.LeftShift)`			: BinaryOperatorLeftShift
	`\(BinaryOperatorKind.Match)`				: BinaryOperatorMatch
	`\(BinaryOperatorKind.Mismatch)`			: BinaryOperatorMismatch
	`\(BinaryOperatorKind.Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperatorKind.Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperatorKind.NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperatorKind.Or)`					: BinaryOperatorOr
	`\(BinaryOperatorKind.Quotient)`			: BinaryOperatorQuotient
	`\(BinaryOperatorKind.RightShift)`			: BinaryOperatorRightShift
	`\(BinaryOperatorKind.Subtraction)`			: BinaryOperatorSubtraction
	`\(BinaryOperatorKind.TypeCasting)`			: BinaryOperatorTypeCasting
	`\(BinaryOperatorKind.TypeEquality)`		: BinaryOperatorTypeEquality
	`\(BinaryOperatorKind.TypeInequality)`		: BinaryOperatorTypeInequality
	`\(BinaryOperatorKind.Xor)`					: BinaryOperatorXor
}

var $expressions = {
	`\(NodeKind.ArrayBinding)`					: ArrayBinding
	`\(NodeKind.ArrayComprehension)`			: func(data, parent, scope) {
		if data.loop.kind == NodeKind.ForFromStatement {
			return ArrayComprehensionForFrom.new(data, parent, scope)
		}
		else if data.loop.kind == NodeKind.ForInStatement {
			return ArrayComprehensionForIn.new(data, parent, scope)
		}
		else if data.loop.kind == NodeKind.ForOfStatement {
			return ArrayComprehensionForOf.new(data, parent, scope)
		}
		else if data.loop.kind == NodeKind.ForRangeStatement {
			return ArrayComprehensionForRange.new(data, parent, scope)
		}
		else if data.loop.kind == NodeKind.RepeatStatement {
			return ArrayComprehensionRepeat.new(data, parent, scope)
		}
		else {
			throw NotSupportedException.new(`Unexpected kind \(data.loop.kind)`, parent)
		}
	}
	`\(NodeKind.ArrayExpression)`				: ArrayExpression
	`\(NodeKind.ArrayRange)`					: ArrayRange
	`\(NodeKind.AwaitExpression)`				: AwaitExpression
	`\(NodeKind.CallExpression)`				: $callExpression
	`\(NodeKind.CascadeExpression)`				: CascadeExpression
	`\(NodeKind.ComparisonExpression)`			: ComparisonExpression
	`\(NodeKind.ConditionalExpression)`			: ConditionalExpression
	`\(NodeKind.CurryExpression)`				: CurryExpression
	`\(NodeKind.DisruptiveExpression)`			: DisruptiveExpression
	`\(NodeKind.FunctionExpression)`			: AnonymousFunctionExpression
	`\(NodeKind.Identifier)`					: IdentifierLiteral
	`\(NodeKind.IfExpression)`					: IfExpression
	`\(NodeKind.LambdaExpression)`				: ArrowFunctionExpression
	`\(NodeKind.Literal)`						: StringLiteral
	`\(NodeKind.MatchExpression)`				: MatchExpression
	`\(NodeKind.MemberExpression)`				: MemberExpression
	`\(NodeKind.NamedArgument)`					: NamedArgument
	`\(NodeKind.NumericExpression)`				: NumberLiteral
	`\(NodeKind.ObjectBinding)`					: ObjectBinding
	`\(NodeKind.ObjectExpression)`				: ObjectExpression
	`\(NodeKind.OmittedExpression)`				: OmittedExpression
	`\(NodeKind.PlaceholderArgument)`			: PlaceholderArgument
	`\(NodeKind.PositionalArgument)`			: PositionalArgument
	`\(NodeKind.Reference)`						: func(data, parent, scope) {
		if var newData ?= parent.getASTReference(data.name) {
			return $compile.expression(newData, parent, scope)
		}

		throw NotSupportedException.new(`Unexpected reference \(data.name)`, parent)
	}
	`\(NodeKind.RegularExpression)`				: RegularExpression
	`\(NodeKind.RestrictiveExpression)`			: RestrictiveExpression
	`\(NodeKind.SequenceExpression)`			: SequenceExpression
	`\(NodeKind.TemplateExpression)`			: TemplateExpression
	`\(NodeKind.TopicReference)`				: func(data, parent, scope) {
		return parent.getTopicReference(data)
	}
	`\(NodeKind.ThisExpression)`				: ThisExpression
	`\(NodeKind.TryExpression)`					: TryExpression
}

var $statements = {
	`\(NodeKind.BitmaskDeclaration)`			: BitmaskDeclaration
	`\(NodeKind.BlockStatement)`				: BlockStatement
	`\(NodeKind.BreakStatement)`				: BreakStatement
	`\(NodeKind.ClassDeclaration)`				: ClassDeclaration
	`\(NodeKind.ContinueStatement)`				: ContinueStatement
	`\(NodeKind.DiscloseDeclaration)`			: DiscloseDeclaration
	`\(NodeKind.DoUntilStatement)`				: DoUntilStatement
	`\(NodeKind.DoWhileStatement)`				: DoWhileStatement
	`\(NodeKind.EnumDeclaration)`				: EnumDeclaration
	`\(NodeKind.ExportDeclaration)`				: ExportDeclaration
	`\(NodeKind.ExpressionStatement)`			: func(data, parent, scope) {
		if data.expression.kind == NodeKind.CallExpression {
			return $callStatement(data, parent, scope)
		}
		else {
			return ExpressionStatement.new(data, parent, scope)
		}
	}
	`\(NodeKind.ExternDeclaration)`				: ExternDeclaration
	`\(NodeKind.ExternOrImportDeclaration)`		: ExternOrImportDeclaration
	`\(NodeKind.ExternOrRequireDeclaration)`	: ExternOrRequireDeclaration
	`\(NodeKind.FallthroughStatement)`			: FallthroughStatement
	`\(NodeKind.ForFromStatement)`				: ForFromStatement
	`\(NodeKind.ForInStatement)`				: ForInStatement
	`\(NodeKind.ForOfStatement)`				: ForOfStatement
	`\(NodeKind.ForRangeStatement)`				: ForRangeStatement
	`\(NodeKind.FunctionDeclaration)`			: FunctionDeclaration
	`\(NodeKind.IfStatement)`					: IfStatement
	`\(NodeKind.ImplementDeclaration)`			: ImplementDeclaration
	`\(NodeKind.ImportDeclaration)`				: ImportDeclaration
	`\(NodeKind.IncludeDeclaration)`			: IncludeDeclaration
	`\(NodeKind.IncludeAgainDeclaration)`		: IncludeAgainDeclaration
	`\(NodeKind.MacroDeclaration)`				: MacroDeclaration
	`\(NodeKind.MatchStatement)`				: MatchStatement
	`\(NodeKind.NamespaceDeclaration)`			: NamespaceDeclaration
	`\(NodeKind.PassStatement)`					: PassStatement
	`\(NodeKind.RepeatStatement)`				: RepeatStatement
	`\(NodeKind.RequireDeclaration)`			: RequireDeclaration
	`\(NodeKind.RequireOrExternDeclaration)`	: RequireOrExternDeclaration
	`\(NodeKind.RequireOrImportDeclaration)`	: RequireOrImportDeclaration
	`\(NodeKind.ReturnStatement)`				: ReturnStatement
	`\(NodeKind.SetStatement)`					: SetStatement
	`\(NodeKind.StructDeclaration)`				: StructDeclaration
	`\(NodeKind.ThrowStatement)`				: ThrowStatement
	`\(NodeKind.TryStatement)`					: TryStatement
	`\(NodeKind.TupleDeclaration)`				: TupleDeclaration
	`\(NodeKind.TypeAliasDeclaration)`			: TypeAliasDeclaration
	`\(NodeKind.UnlessStatement)`				: UnlessStatement
	`\(NodeKind.UntilStatement)`				: UntilStatement
	`\(NodeKind.VariableStatement)`				: VariableStatement
	`\(NodeKind.WhileStatement)`				: WhileStatement
	`\(NodeKind.WithStatement)`					: WithStatement
}

var $polyadicOperators = {
	`\(BinaryOperatorKind.Addition)`			: PolyadicOperatorAddition
	`\(BinaryOperatorKind.And)`					: PolyadicOperatorAnd
	`\(BinaryOperatorKind.Division)`			: PolyadicOperatorDivision
	`\(BinaryOperatorKind.EmptyCoalescing)`		: PolyadicOperatorEmptyCoalescing
	`\(BinaryOperatorKind.Modulo)`				: PolyadicOperatorModulo
	`\(BinaryOperatorKind.Imply)`				: PolyadicOperatorImply
	`\(BinaryOperatorKind.LeftShift)`			: PolyadicOperatorLeftShift
	`\(BinaryOperatorKind.Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperatorKind.NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperatorKind.Or)`					: PolyadicOperatorOr
	`\(BinaryOperatorKind.Quotient)`			: PolyadicOperatorQuotient
	`\(BinaryOperatorKind.RightShift)`			: PolyadicOperatorRightShift
	`\(BinaryOperatorKind.Subtraction)`			: PolyadicOperatorSubtraction
	`\(BinaryOperatorKind.Xor)`					: PolyadicOperatorXor
}

var $unaryOperators = {
	`\(UnaryOperatorKind.Existential)`			: UnaryOperatorExistential
	`\(UnaryOperatorKind.ForcedTypeCasting)`	: UnaryOperatorForcedTypeCasting
	`\(UnaryOperatorKind.Implicit)`				: UnaryOperatorImplicit
	`\(UnaryOperatorKind.Negation)`				: UnaryOperatorNegation
	`\(UnaryOperatorKind.Negative)`				: UnaryOperatorNegative
	`\(UnaryOperatorKind.NonEmpty)`				: UnaryOperatorNonEmpty
	`\(UnaryOperatorKind.NullableTypeCasting)`	: UnaryOperatorNullableTypeCasting
	`\(UnaryOperatorKind.Spread)`				: UnaryOperatorSpread
}
