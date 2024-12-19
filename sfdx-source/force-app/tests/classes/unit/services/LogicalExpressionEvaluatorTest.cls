@isTest
private without sharing class LogicalExpressionEvaluatorTest {
    @isTest
    static void testWhenInputAndValidExpressionThenReturnValidOutcome() {
        String logicalExpression = ' ((  ((  6 and (5 OR 4 56)) OR 3) AND 2 OR 1 )) ';
        Map<Integer, boolean> logicalExpressionOperandToOutcome = new Map<Integer, boolean>{
            1 => true,
            2 => false,
            3 => true,
            456 => false,
            5 => true,
            6 => false
        };
        Boolean expectedOutcome = ((((logicalExpressionOperandToOutcome.get(6) &&
        (logicalExpressionOperandToOutcome.get(5) || logicalExpressionOperandToOutcome.get(456))) ||
        logicalExpressionOperandToOutcome.get(3)) && logicalExpressionOperandToOutcome.get(2) ||
        logicalExpressionOperandToOutcome.get(1)));
        System.assertEquals(
            expectedOutcome,
            LogicalExpressionEvaluator.getOutcome(
                logicalExpressionOperandToOutcome,
                logicalExpression
            ),
            String.format(
                'Expect logical expression [[0]] of input [[{1}]] to evaluate to {2}; actual {3}',
                new List<Object>{
                    logicalExpression,
                    logicalExpressionOperandToOutcome,
                    expectedOutcome,
                    LogicalExpressionEvaluator.getOutcome(logicalExpressionOperandToOutcome)
                }
            )
        );
    }

    @isTest
    static void testWhenInputAndNoExpressionThenReturnDefaultOutcome() {
        Map<Integer, boolean> logicalExpressionOperandToOutcome = new Map<Integer, boolean>{
            1 => true,
            2 => false,
            3 => true,
            456 => false,
            5 => true,
            6 => false
        };
        Boolean expectedOutcome =
            logicalExpressionOperandToOutcome.get(1) &&
            logicalExpressionOperandToOutcome.get(2) &&
            logicalExpressionOperandToOutcome.get(3) &&
            logicalExpressionOperandToOutcome.get(456) &&
            logicalExpressionOperandToOutcome.get(5) &&
            logicalExpressionOperandToOutcome.get(6);
        System.assertEquals(
            expectedOutcome,
            LogicalExpressionEvaluator.getOutcome(logicalExpressionOperandToOutcome),
            String.format(
                'Expect default outcome of input [[{0}]] to evaluate to {1}; actual {2}',
                new List<Object>{
                    logicalExpressionOperandToOutcome,
                    expectedOutcome,
                    LogicalExpressionEvaluator.getOutcome(logicalExpressionOperandToOutcome)
                }
            )
        );
    }

    @isTest
    static void testWhenUnbalancedTooFewLeftParenthesisThenException() {
        String logicalExpression = ' ((  ((  6 and (5 OR 4 56)))) OR 3) AND 2 OR 1 )) ';
        Map<Integer, boolean> logicalExpressionOperandToOutcome = new Map<Integer, boolean>{
            1 => true,
            2 => false,
            3 => true,
            456 => false,
            5 => true,
            6 => false
        };
        try {
            LogicalExpressionEvaluator.getOutcome(
                logicalExpressionOperandToOutcome,
                logicalExpression
            );
        } catch (LogicalExpressionEvaluator.LogicalExpressionEvaluatorException ex) {
            System.assertEquals(
                'Mismatched parentheses in logical expression',
                ex.getMessage(),
                String.format(
                    'Expected Exception message [[{0}]]; actual [[{1}]]',
                    new List<Object>{
                        'Mismatched parentheses in logical expression',
                        ex.getMessage()
                    }
                )
            );
        }
    }

    @isTest
    static void testWhenUnbalancedTooManyLeftParenthesisThenException() {
        String logicalExpression = ' ((  ((  6 and (((5 OR 4 56)) OR 3) AND 2 OR 1 )) ';
        Map<Integer, boolean> logicalExpressionOperandToOutcome = new Map<Integer, boolean>{
            1 => true,
            2 => false,
            3 => true,
            456 => false,
            5 => true,
            6 => false
        };
        try {
            LogicalExpressionEvaluator.getOutcome(
                logicalExpressionOperandToOutcome,
                logicalExpression
            );
        } catch (LogicalExpressionEvaluator.LogicalExpressionEvaluatorException ex) {
            System.assertEquals(
                'Mismatched parentheses in logical expression',
                ex.getMessage(),
                String.format(
                    'Expected Exception message [[{0}]]; actual [[{1}]]',
                    new List<Object>{
                        'Mismatched parentheses in logical expression',
                        ex.getMessage()
                    }
                )
            );
        }
    }
}