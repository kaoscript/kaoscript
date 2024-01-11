var $assignmentOperators = {
	[OperatorKind.Addition]				: AssignmentOperatorAddition
	[OperatorKind.BitwiseAnd]			: AssignmentOperatorBitwiseAnd
	[OperatorKind.BitwiseLeftShift]		: AssignmentOperatorBitwiseLeftShift
	[OperatorKind.BitwiseOr]			: AssignmentOperatorBitwiseOr
	[OperatorKind.BitwiseRightShift]	: AssignmentOperatorBitwiseRightShift
	[OperatorKind.BitwiseXor]			: AssignmentOperatorBitwiseXor
	[OperatorKind.Division]				: AssignmentOperatorDivision
	[OperatorKind.Empty]				: AssignmentOperatorEmpty
	[OperatorKind.EmptyCoalescing]		: AssignmentOperatorEmptyCoalescing
	[OperatorKind.Equals]				: AssignmentOperatorEquals
	[OperatorKind.Existential]			: AssignmentOperatorExistential
	[OperatorKind.Finite]				: AssignmentOperatorFinite
	[OperatorKind.IntegerDivision]		: AssignmentOperatorDivisionInteger
	[OperatorKind.LogicalAnd]			: AssignmentOperatorLogicalAnd
	[OperatorKind.LogicalOr]			: AssignmentOperatorLogicalOr
	[OperatorKind.LogicalXor]			: AssignmentOperatorLogicalXor
	[OperatorKind.Modulus]				: AssignmentOperatorModulus
	[OperatorKind.Multiplication]		: AssignmentOperatorMultiplication
	[OperatorKind.NonEmpty]				: AssignmentOperatorNonEmpty
	[OperatorKind.NonExistential]		: AssignmentOperatorNonExistential
	[OperatorKind.NonFinite]			: AssignmentOperatorNonFinite
	[OperatorKind.NonFiniteCoalescing]	: AssignmentOperatorNonFiniteCoalescing
	[OperatorKind.NullCoalescing]		: AssignmentOperatorNullCoalescing
	[OperatorKind.Power]				: AssignmentOperatorPower
	[OperatorKind.Remainder]			: AssignmentOperatorRemainder
	[OperatorKind.Return]				: AssignmentOperatorReturn
	[OperatorKind.Subtraction]			: AssignmentOperatorSubtraction
	[OperatorKind.VariantNo]			: AssignmentOperatorVariantNo
	[OperatorKind.VariantNoCoalescing]	: AssignmentOperatorVariantCoalescing
	[OperatorKind.VariantYes]			: AssignmentOperatorVariantYes
}

var $binaryOperators = {
	[OperatorKind.Addition]				: BinaryOperatorAddition
	[OperatorKind.BackwardPipeline]		: BinaryOperatorBackwardPipeline
	[OperatorKind.BitwiseAnd]			: PolyadicOperatorBitwiseAnd
	[OperatorKind.BitwiseLeftShift]		: PolyadicOperatorBitwiseLeftShift
	[OperatorKind.BitwiseOr]			: PolyadicOperatorBitwiseOr
	[OperatorKind.BitwiseRightShift]	: PolyadicOperatorBitwiseRightShift
	[OperatorKind.BitwiseXor]			: PolyadicOperatorBitwiseXor
	[OperatorKind.Division]				: BinaryOperatorDivision
	[OperatorKind.EmptyCoalescing]		: BinaryOperatorEmptyCoalescing
	[OperatorKind.EuclideanDivision]	: BinaryOperatorDivisionEuclidean
	[OperatorKind.ForwardPipeline]		: BinaryOperatorForwardPipeline
	[OperatorKind.IntegerDivision]		: BinaryOperatorDivisionInteger
	[OperatorKind.LogicalAnd]			: PolyadicOperatorLogicalAnd
	[OperatorKind.LogicalImply]			: PolyadicOperatorLogicalImply
	[OperatorKind.LogicalOr]			: PolyadicOperatorLogicalOr
	[OperatorKind.LogicalXor]			: PolyadicOperatorLogicalXor
	[OperatorKind.Match]				: BinaryOperatorMatch
	[OperatorKind.Mismatch]				: BinaryOperatorMismatch
	[OperatorKind.Modulus]				: BinaryOperatorModulus
	[OperatorKind.Multiplication]		: BinaryOperatorMultiplication
	[OperatorKind.NonFiniteCoalescing]	: BinaryOperatorNonFiniteCoalescing
	[OperatorKind.NullCoalescing]		: BinaryOperatorNullCoalescing
	[OperatorKind.Power]				: BinaryOperatorPower
	[OperatorKind.Remainder]			: BinaryOperatorRemainder
	[OperatorKind.Subtraction]			: BinaryOperatorSubtraction
	[OperatorKind.TypeAssertion]		: BinaryOperatorTypeAssertion
	[OperatorKind.TypeCasting]			: BinaryOperatorTypeCasting
	[OperatorKind.TypeEquality]			: BinaryOperatorTypeEquality
	[OperatorKind.TypeInequality]		: BinaryOperatorTypeInequality
	[OperatorKind.TypeSignalment]		: BinaryOperatorTypeSignalment
	[OperatorKind.VariantNoCoalescing]	: BinaryOperatorVariantCoalescing
}

var $expressions = {
	[NodeKind.ArrayBinding]					: ArrayBinding
	[NodeKind.ArrayComprehension]			: func(data, parent, scope) {
		match data.loop.kind {
			NodeKind.ForStatement {
				return match data.loop.iteration.kind {
					IterationKind.Array => ArrayComprehensionForIn.new(data, parent, scope)
					IterationKind.From => ArrayComprehensionForFrom.new(data, parent, scope)
					IterationKind.Object => ArrayComprehensionForOf.new(data, parent, scope)
					IterationKind.Range => ArrayComprehensionForRange.new(data, parent, scope)
					// TODO remove else
					else => throw NotImplementedException.new()
				}
			}
			NodeKind.RepeatStatement {
				return ArrayComprehensionRepeat.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected kind \(data.loop.kind)`, parent)
			}
		}
	}
	[NodeKind.ArrayExpression]				: ArrayExpression
	[NodeKind.ArrayRange]					: ArrayRange
	[NodeKind.AwaitExpression]				: AwaitExpression
	[NodeKind.CallExpression]				: $callExpression
	[NodeKind.ComparisonExpression]			: ComparisonExpression
	[NodeKind.ConditionalExpression]		: ConditionalExpression
	[NodeKind.CurryExpression]				: CurryExpression
	[NodeKind.DisruptiveExpression]			: DisruptiveExpression
	[NodeKind.FunctionExpression]			: AnonymousFunctionExpression
	[NodeKind.Identifier]					: IdentifierLiteral
	[NodeKind.IfExpression]					: IfExpression
	[NodeKind.LambdaExpression]				: ArrowFunctionExpression
	[NodeKind.Literal]						: StringLiteral
	[NodeKind.MatchExpression]				: MatchExpression
	[NodeKind.MemberExpression]				: MemberExpression
	[NodeKind.NamedArgument]				: NamedArgument
	[NodeKind.NumericExpression]			: NumberLiteral
	[NodeKind.ObjectBinding]				: ObjectBinding
	[NodeKind.ObjectComprehension]			: ObjectComprehension
	[NodeKind.ObjectExpression]				: ObjectExpression
	[NodeKind.OmittedExpression]			: OmittedExpression
	[NodeKind.PlaceholderArgument]			: PlaceholderArgument
	[NodeKind.PositionalArgument]			: PositionalArgument
	[NodeKind.Reference]					: func(data, parent, scope) {
		if var expression ?= parent.getASTReference(data.name) {
			return ReferenceExpression.new(expression, data, parent, scope)
		}

		throw NotSupportedException.new(`Unexpected reference \(data.name)`, parent)
	}
	[NodeKind.RegularExpression]			: RegularExpression
	[NodeKind.RestrictiveExpression]		: RestrictiveExpression
	[NodeKind.RollingExpression]			: RollingExpression
	[NodeKind.SequenceExpression]			: SequenceExpression
	[NodeKind.TemplateExpression]			: TemplateExpression
	[NodeKind.TopicReference]				: func(data, parent, scope) {
		return parent.getTopicReference(data)
	}
	[NodeKind.ThisExpression]				: ThisExpression
	[NodeKind.TryExpression]				: TryExpression
	[NodeKind.TypedExpression]				: TypedExpression
}

var $statements = {
	[NodeKind.BitmaskDeclaration]			: BitmaskDeclaration
	[NodeKind.BlockStatement]				: BlockStatement
	[NodeKind.BreakStatement]				: BreakStatement
	[NodeKind.ClassDeclaration]				: ClassDeclaration
	[NodeKind.ContinueStatement]			: ContinueStatement
	[NodeKind.DiscloseDeclaration]			: DiscloseDeclaration
	[NodeKind.DoUntilStatement]				: DoUntilStatement
	[NodeKind.DoWhileStatement]				: DoWhileStatement
	[NodeKind.EnumDeclaration]				: EnumDeclaration
	[NodeKind.ExportDeclaration]			: ExportDeclaration
	[NodeKind.ExpressionStatement]			: func(data, parent, scope) {
		if data.expression.kind == NodeKind.CallExpression {
			return $callStatement(data, parent, scope)
		}
		else {
			return ExpressionStatement.new(data, parent, scope)
		}
	}
	[NodeKind.ExternDeclaration]			: ExternDeclaration
	[NodeKind.ExternOrImportDeclaration]	: ExternOrImportDeclaration
	[NodeKind.ExternOrRequireDeclaration]	: ExternOrRequireDeclaration
	[NodeKind.FallthroughStatement]			: FallthroughStatement
	[NodeKind.ForStatement]					: ForStatement
	[NodeKind.FunctionDeclaration]			: FunctionDeclaration
	[NodeKind.IfStatement]					: IfStatement
	[NodeKind.ImplementDeclaration]			: ImplementDeclaration
	[NodeKind.ImportDeclaration]			: ImportDeclaration
	[NodeKind.IncludeDeclaration]			: IncludeDeclaration
	[NodeKind.IncludeAgainDeclaration]		: IncludeAgainDeclaration
	[NodeKind.MacroDeclaration]				: MacroDeclaration
	[NodeKind.MatchStatement]				: MatchStatement
	[NodeKind.NamespaceDeclaration]			: NamespaceDeclaration
	[NodeKind.PassStatement]				: PassStatement
	[NodeKind.RepeatStatement]				: RepeatStatement
	[NodeKind.RequireDeclaration]			: RequireDeclaration
	[NodeKind.RequireOrExternDeclaration]	: RequireOrExternDeclaration
	[NodeKind.RequireOrImportDeclaration]	: RequireOrImportDeclaration
	[NodeKind.ReturnStatement]				: ReturnStatement
	[NodeKind.SetStatement]					: SetStatement
	[NodeKind.StructDeclaration]			: StructDeclaration
	[NodeKind.ThrowStatement]				: ThrowStatement
	[NodeKind.TryStatement]					: TryStatement
	[NodeKind.TupleDeclaration]				: TupleDeclaration
	[NodeKind.TypeAliasDeclaration]			: TypeAliasDeclaration
	[NodeKind.UnlessStatement]				: UnlessStatement
	[NodeKind.UntilStatement]				: UntilStatement
	[NodeKind.VariableStatement]			: VariableStatement
	[NodeKind.WhileStatement]				: WhileStatement
	[NodeKind.WithStatement]				: WithStatement
}

var $polyadicOperators = {
	[OperatorKind.Addition]				: PolyadicOperatorAddition
	[OperatorKind.BitwiseAnd]			: PolyadicOperatorBitwiseAnd
	[OperatorKind.BitwiseLeftShift]		: PolyadicOperatorBitwiseLeftShift
	[OperatorKind.BitwiseOr]			: PolyadicOperatorBitwiseOr
	[OperatorKind.BitwiseRightShift]	: PolyadicOperatorBitwiseRightShift
	[OperatorKind.BitwiseXor]			: PolyadicOperatorBitwiseXor
	[OperatorKind.Division]				: PolyadicOperatorDivision
	[OperatorKind.EmptyCoalescing]		: PolyadicOperatorEmptyCoalescing
	[OperatorKind.IntegerDivision]		: PolyadicOperatorDivisionInteger
	[OperatorKind.LogicalAnd]			: PolyadicOperatorLogicalAnd
	[OperatorKind.LogicalImply]			: PolyadicOperatorLogicalImply
	[OperatorKind.LogicalOr]			: PolyadicOperatorLogicalOr
	[OperatorKind.LogicalXor]			: PolyadicOperatorLogicalXor
	[OperatorKind.Modulus]				: PolyadicOperatorModulus
	[OperatorKind.Multiplication]		: PolyadicOperatorMultiplication
	[OperatorKind.NonFiniteCoalescing]	: PolyadicOperatorNonFiniteCoalescing
	[OperatorKind.NullCoalescing]		: PolyadicOperatorNullCoalescing
	[OperatorKind.Power]				: PolyadicOperatorPower
	[OperatorKind.Remainder]			: PolyadicOperatorRemainder
	[OperatorKind.Subtraction]			: PolyadicOperatorSubtraction
	[OperatorKind.VariantNoCoalescing]	: PolyadicOperatorVariantCoalescing
}

var $unaryOperators = {
	[OperatorKind.BitwiseNegation]		: UnaryOperatorBitwiseNegation
	[OperatorKind.Existential]			: UnaryOperatorExistential
	[OperatorKind.Finite]				: UnaryOperatorFinite
	[OperatorKind.Implicit]				: UnaryOperatorImplicit
	[OperatorKind.Length]				: UnaryOperatorLength
	[OperatorKind.LogicalNegation]		: UnaryOperatorLogicalNegation
	[OperatorKind.Negative]				: UnaryOperatorNegative
	[OperatorKind.NonEmpty]				: UnaryOperatorNonEmpty
	[OperatorKind.Spread]				: UnaryOperatorSpread
	[OperatorKind.TypeFitting]			: UnaryOperatorTypeFitting
	[OperatorKind.VariantYes]			: UnaryOperatorVariant
}
