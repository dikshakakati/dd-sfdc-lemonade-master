/**
 * @description tokenizes a logical expression
 */
@SuppressWarnings('PMD.ApexCRUDViolation, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class LogicalStringExpressionTokenizer {
    //Tokens are '(', ')', 'OR', 'AND' and string integer e.g. '1', '2', '3', '4' ...
    //final Set<Integer> NON_INTEGER_CHARS = new set<Integer>

    /**
     * @description tokenize a logical expression
     * @param stringToTokenize used to identify the correct derive type to return
     * @return List<String>
     */
    public static List<String> tokenize(String stringToTokenize) {
        List<String> tokens = new List<String>();
        Integer[] chars = stringToTokenize.remove(' ').getChars();
        List<Integer> currentTokenChars = new List<Integer>();
        for (Integer c : chars) {
            if (!isValid(c)) {
                String exceptionMessage = String.format(
                    'Invalid character {0} found.',
                    new List<String>{ String.fromCharArray(new List<Integer>{ c }) }
                );
                throw new LogicalStringExpressionTokenizerException(exceptionMessage);
            }
            if (isParenthesis(c)) {
                if (!currentTokenChars.isEmpty()) {
                    tokens.add(String.fromCharArray(currentTokenChars));
                    currentTokenChars = new List<Integer>();
                }
                tokens.add(String.fromCharArray(new List<Integer>{ c }));
                continue;
            }
            if (isAlphabet(c)) {
                if (!currentTokenChars.isEmpty() && !isAlphabet(currentTokenChars[0])) {
                    tokens.add(String.fromCharArray(currentTokenChars));
                    currentTokenChars = new List<Integer>();
                }
                currentTokenChars.add(c);
                continue;
            }
            if (isNumeric(c)) {
                if (!currentTokenChars.isEmpty() && !isNumeric(currentTokenChars[0])) {
                    tokens.add(String.fromCharArray(currentTokenChars));
                    currentTokenChars = new List<Integer>();
                }
                currentTokenChars.add(c);
            }
        }
        if (!currentTokenChars.isEmpty()) {
            tokens.add(String.fromCharArray(currentTokenChars));
        }
        return tokens;
    }

    /**
     * @description check if character is numberic
     * @param charToInteger integer representation of an Ascii character
     * @return Boolean
     */
    public static Boolean isNumeric(Integer charToInteger) {
        return charToInteger >= 48 && charToInteger <= 57;
    }

    /**
     * @description check if character is an alphabet
     * @param charToInteger integer representation of an Ascii character
     * @return Boolean
     */
    public static Boolean isAlphabet(Integer charToInteger) {
        return (charToInteger >= 65 && charToInteger <= 90) ||
            (charToInteger >= 97 &&
            charToInteger <= 122);
    }

    /**
     * @description check if character is a parenthesis
     * @param charToInteger integer representation of an Ascii character
     * @return Boolean
     */
    public static Boolean isParenthesis(Integer charToInteger) {
        return charToInteger == 40 || charToInteger == 41;
    }

    /**
     * @description check if character is either integer, alphabet or parenthesis
     * @param charToInteger integer representation of an Ascii character
     * @return Boolean
     */
    public static Boolean isValid(Integer charToInteger) {
        return isParenthesis(charToInteger) ||
            isNumeric(charToInteger) ||
            isAlphabet(charToInteger);
    }

    /**
     * @description LogicalStringExpressionTokenizer's exception class
     */
    public class LogicalStringExpressionTokenizerException extends Exception {
    }
}