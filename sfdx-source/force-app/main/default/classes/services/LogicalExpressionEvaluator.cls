/**
 * @description evaluates outcome for an input with or without logical expression
 */
@SuppressWarnings('PMD.ApexCRUDViolation, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class LogicalExpressionEvaluator {
    @testVisible
    static Boolean getOutcome(Map<Integer, Boolean> input) {
        Boolean outcome = true;
        for (Boolean subOutcome : input.values()) {
            outcome = outcome && subOutcome;
        }
        return outcome;
    }
    //shunting yard algorithm

    /**
     * @description constructor
     * @param input to run through logicalExpression
     * @param logicalExpression used to evaluate outcome of input
     * @return Boolean
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    public static Boolean getOutcome(Map<Integer, Boolean> input, String logicalExpression) {
        if (String.isBlank(logicalExpression)) {
            return getOutcome(input);
        }
        List<String> tokenizedExpression = LogicalStringExpressionTokenizer.tokenize(
            logicalExpression.toUpperCase()
        );
        Stack operandStack = new Stack(tokenizedExpression.size());
        Stack operatorStack = new Stack(tokenizedExpression.size());

        for (String token : tokenizedExpression) {
            if (isOperand(token)) {
                operandStack.push(input.get(Integer.valueOf(token)));
                continue;
            }
            if (isParenthesis(token) && token == '(') {
                operatorStack.push(token);
                continue;
            }
            if (isOperator(token)) {
                String operatorStackTop;
                while (operatorStack.hasNext()) {
                    operatorStackTop = (String) operatorStack.peek();
                    if (
                        operatorStackTop.equals('(') ||
                        (!token.equalsIgnoreCase(operatorStackTop) &&
                        !operatorStackTop.equalsIgnoreCase('AND'))
                    ) {
                        break;
                    }
                    operandStack.push(
                        outcome(
                            (Boolean) operandStack.pop(),
                            (Boolean) operandStack.pop(),
                            (String) operatorStack.pop()
                        )
                    );
                }
                operatorStack.push(token);
                continue;
            }
            if (isParenthesis(token) && token == ')') {
                String operatorStackTop;
                while (operatorStack.hasNext()) {
                    operatorStackTop = (String) operatorStack.peek();
                    if (operatorStackTop.equals('(')) {
                        break;
                    }
                    operandStack.push(
                        outcome(
                            (Boolean) operandStack.pop(),
                            (Boolean) operandStack.pop(),
                            (String) operatorStack.pop()
                        )
                    );
                }
                if (!operatorStack.hasNext() || !((String) operatorStack.peek()).equals('(')) {
                    throw new LogicalExpressionEvaluatorException(
                        'Mismatched parentheses in logical expression'
                    );
                }
                operatorStack.pop();
            }
        }
        String operatorStackTop;
        while (operatorStack.hasNext()) {
            operatorStackTop = (String) operatorStack.peek();
            if (operatorStackTop.equals('(')) {
                throw new LogicalExpressionEvaluatorException(
                    'Mismatched parentheses in logical expression'
                );
            }
            operandStack.push(
                outcome(
                    (Boolean) operandStack.pop(),
                    (Boolean) operandStack.pop(),
                    (String) operatorStack.pop()
                )
            );
        }
        return ((Boolean) operandStack.pop());
    }

    static Boolean outcome(Boolean rightOperand, Boolean leftOperand, String operator) {
        return (operator.equalsIgnoreCase('AND')
            ? (leftOperand && rightOperand)
            : (leftOperand || rightOperand));
    }

    static Boolean isOperand(String token) {
        return LogicalStringExpressionTokenizer.isNumeric(token.getChars()[0]);
    }

    static Boolean isParenthesis(String token) {
        return LogicalStringExpressionTokenizer.isParenthesis(token.getChars()[0]);
    }

    static Boolean isOperator(String token) {
        return LogicalStringExpressionTokenizer.isAlphabet(token.getChars()[0]);
    }

    /**
     * @description Stack data structure
     */
    public class Stack { //array Implementation of stack
        Integer stackSize;
        Integer top;
        Object[] stackArray;
        /**
         * @description constructor
         * @param size stack size
         */
        public Stack(Integer size) {
            stackSize = size;
            stackArray = new List<Object>(stackSize);
            top = -1;
        }

        /**
         * @description get value at the top of the stack without removing it
         * @return  Object
         */
        public Object peek() {
            if (top < 0) {
                throw new StackException('Stack is empty.');
            }
            return stackArray[top];
        }

        /**
         * @description push value on top of stack
         * @param objToPush to push into stack
         */
        public void push(Object objToPush) {
            if (top >= stackSize - 1) {
                throw new StackException('Stack is full.');
            }
            top++;
            stackArray[top] = objToPush;
        }

        /**
         * @description remove top value of the stack
         * @return Object
         */
        public Object pop() {
            if (top < 0) {
                throw new StackException('Stack is empty.');
            }
            Object obj = stackArray[top];
            top--;
            return obj;
        }

        /**
         * @description check if stack has an element
         * @return Boolean
         */
        public Boolean hasNext() {
            return top >= 0;
        }
    }

    /**
     * @description Stack's exception class
     */
    public class StackException extends Exception {
    }

    /**
     * @description LogicalExpressionEvaluator's exception class
     */
    public class LogicalExpressionEvaluatorException extends Exception {
    }
}