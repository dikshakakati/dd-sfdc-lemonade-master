@isTest
private without sharing class LogicalStringExpressionTokenizerTest {
    static final String ASCII_CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*()-=_+[]\\{}|;\':",./<>?';
    static final String PARENTHESES = '()';
    static final String NUMERIC_CHARS = '0123456789';
    static final String ALPHA_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    @isTest
    static void testWhenNotParthensisThenIsParenthesisReturnsFalseElseTrue() {
        String char2String;
        for (Integer char2int : ASCII_CHARS.getChars()) {
            char2String = String.fromCharArray(new List<Integer>{ char2int });
            if (!PARENTHESES.contains(char2String)) {
                System.assertEquals(
                    false,
                    LogicalStringExpressionTokenizer.isParenthesis(char2int),
                    String.format(
                        'Expected false on parenthesis check for char: {0}, actual: true',
                        new List<Object>{ char2String }
                    )
                );
                continue;
            }
            System.assertEquals(
                true,
                LogicalStringExpressionTokenizer.isParenthesis(char2int),
                String.format(
                    'Expected true on parenthesis check for char: {0}, actual: false',
                    new List<Object>{ char2String }
                )
            );
        }
    }

    @isTest
    static void testWhenNonNumericThenIsNumericReturnsFalseElseTrue() {
        String char2String;
        for (Integer char2int : ASCII_CHARS.getChars()) {
            char2String = String.fromCharArray(new List<Integer>{ char2int });
            if (!NUMERIC_CHARS.contains(char2String)) {
                System.assertEquals(
                    false,
                    LogicalStringExpressionTokenizer.isNumeric(char2int),
                    String.format(
                        'Expected false on numeric check for char: {0}, actual: true',
                        new List<Object>{ char2String }
                    )
                );
                continue;
            }
            System.assertEquals(
                true,
                LogicalStringExpressionTokenizer.isNumeric(char2int),
                String.format(
                    'Expected true on numeric check for char: {0}, actual: false',
                    new List<Object>{ char2String }
                )
            );
        }
    }

    @isTest
    static void testWhenIsNotAlphabetThenReturnsFalseElseTrue() {
        String char2String;
        for (Integer char2int : ASCII_CHARS.getChars()) {
            char2String = String.fromCharArray(new List<Integer>{ char2int });
            if (!ALPHA_CHARS.contains(char2String)) {
                System.assertEquals(
                    false,
                    LogicalStringExpressionTokenizer.isAlphabet(char2int),
                    String.format(
                        'Expected false on alphabet check for char: {0}, actual: true',
                        new List<Object>{ char2String }
                    )
                );
                continue;
            }
            System.assertEquals(
                true,
                LogicalStringExpressionTokenizer.isAlphabet(char2int),
                String.format(
                    'Expected true on alphabet check for char: {0}, actual: false',
                    new List<Object>{ char2String }
                )
            );
        }
    }

    @isTest
    static void testWhenInvalidLogicalCharThenIsValidReturnsFalseElseTrue() {
        String char2String;
        for (Integer char2int : ASCII_CHARS.getChars()) {
            char2String = String.fromCharArray(new List<Integer>{ char2int });
            if (
                PARENTHESES.contains(char2String) ||
                NUMERIC_CHARS.contains(char2String) ||
                ALPHA_CHARS.contains(char2String)
            ) {
                System.assertEquals(
                    true,
                    LogicalStringExpressionTokenizer.isValid(char2int),
                    String.format(
                        'Expected true on validity check for char: {0}, actual: false',
                        new List<Object>{ char2String }
                    )
                );
                continue;
            }
            System.assertEquals(
                false,
                LogicalStringExpressionTokenizer.isValid(char2int),
                String.format(
                    'Expected false on validity check for char: {0}, actual: true',
                    new List<Object>{ char2String }
                )
            );
        }
    }

    @isTest
    static void testWhenValidLogicalExpressionThenReturnCorrectTokens() {
        string logicalExpression = ' ((  ((  6 and (5 OR 4 56)) OR 3) AND 2 OR 1 )) ';
        Set<String> tokens = new Set<String>{
            '(',
            '(',
            '(',
            '(',
            '6',
            'and',
            '(',
            '5',
            'OR',
            '456',
            ')',
            ')',
            'OR',
            '3',
            ')',
            'AND',
            '2',
            'OR',
            '1',
            ')',
            ')'
        };
        for (String token : LogicalStringExpressionTokenizer.tokenize(logicalExpression)) {
            System.assertEquals(
                true,
                tokens.contains(token),
                String.format(
                    'The set: {0} does not contain token: {1}',
                    new List<Object>{ tokens, token }
                )
            );
        }
    }

    @isTest
    static void testWhenInvalidLogicalExpressionThenException() {
        String char2String;
        for (Integer char2int : ASCII_CHARS.getChars()) {
            char2String = String.fromCharArray(new List<Integer>{ char2int });
            if (
                PARENTHESES.contains(char2String) ||
                NUMERIC_CHARS.contains(char2String) ||
                ALPHA_CHARS.contains(char2String)
            ) {
                continue;
            }
            try {
                LogicalStringExpressionTokenizer.tokenize(char2String);
            } catch (LogicalStringExpressionTokenizer.LogicalStringExpressionTokenizerException ex) {
                System.assertEquals(
                    String.format('Invalid character {0} found.', new List<Object>{ char2String }),
                    ex.getMessage(),
                    String.format(
                        'Expected message: {0}; actual: {1}',
                        new List<Object>{
                            String.format(
                                'Invalid character {0} found.',
                                new List<Object>{ char2String }
                            ),
                            ex.getMessage()
                        }
                    )
                );
            }
        }
    }
}