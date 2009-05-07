// $ANTLR 3.1.1 /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g 2009-03-13 16:56:21

package de.tum.in.isabelle.Kodkodi;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class KodkodiLexer extends Lexer {
    public static final int COMMA=7;
    public static final int MINUS=32;
    public static final int HASH=40;
    public static final int SKOLEM_DEPTH=12;
    public static final int REL_EXPR_REG=27;
    public static final int NAT=89;
    public static final int FALSE=15;
    public static final int BRACE_RIGHT=41;
    public static final int THEN=51;
    public static final int TILDE=82;
    public static final int SHARING=10;
    public static final int SHR=70;
    public static final int DOT=78;
    public static final int TUPLE_NAME=45;
    public static final int BRACKET_LEFT=23;
    public static final int AND=33;
    public static final int ACYCLIC=63;
    public static final int FUNCTION=64;
    public static final int RELATION_NAME=22;
    public static final int IMPLIES=55;
    public static final int LE=59;
    public static final int AMP=75;
    public static final int PLUS=31;
    public static final int BRACKET_RIGHT=24;
    public static final int INT_BOUNDS=25;
    public static final int MODULO=73;
    public static final int FLATTEN=13;
    public static final int IDEN=80;
    public static final int ONE=65;
    public static final int NONE=42;
    public static final int EQ=57;
    public static final int TOTAL_ORDERING=67;
    public static final int LONE=66;
    public static final int INLINE_COMMENT=91;
    public static final int LT=58;
    public static final int ATOM_NAME=44;
    public static final int RELATION=93;
    public static final int GE=61;
    public static final int ELSE=52;
    public static final int OFFSET_UNIV_NAME=35;
    public static final int HAT=74;
    public static final int SEMICOLON=30;
    public static final int COLON=5;
    public static final int INTS=81;
    public static final int ALL=43;
    public static final int PAREN_LEFT=36;
    public static final int SET=88;
    public static final int COLON_EQ=19;
    public static final int SOLVER=4;
    public static final int SYMMETRY_BREAKING=8;
    public static final int TRUE=14;
    public static final int SOLVE=29;
    public static final int UNIV_NAME=17;
    public static final int BITS=85;
    public static final int SHL=68;
    public static final int INT_EXPR_REG=28;
    public static final int ARROW=34;
    public static final int DOT_DOT=39;
    public static final int OR=53;
    public static final int BRACE_LEFT=38;
    public static final int TUPLE_SET_REG=18;
    public static final int DIVIDE=72;
    public static final int BIT_WIDTH=11;
    public static final int IFF=54;
    public static final int UNIV=16;
    public static final int INT=86;
    public static final int PAREN_RIGHT=37;
    public static final int SHA=69;
    public static final int STR_LITERAL=6;
    public static final int SUM=48;
    public static final int FORMULA_REG=26;
    public static final int BOUNDS=21;
    public static final int BLOCK_COMMENT=92;
    public static final int GT=60;
    public static final int NO=87;
    public static final int OVERRIDE=76;
    public static final int WHITESPACE=90;
    public static final int IN=62;
    public static final int SGN=84;
    public static final int TUPLE_REG=20;
    public static final int SOME=47;
    public static final int ABS=83;
    public static final int BAR=46;
    public static final int LET=49;
    public static final int IF=50;
    public static final int EOF=-1;
    public static final int NUM=9;
    public static final int IFNO=77;
    public static final int STAR=71;
    public static final int NOT=56;
    public static final int VARIABLE_NAME=79;

    public void emitErrorMessage(String message) {
        System.err.println(message);
        System.exit(1);
    }


    // delegates
    // delegators

    public KodkodiLexer() {;} 
    public KodkodiLexer(CharStream input) {
        this(input, new RecognizerSharedState());
    }
    public KodkodiLexer(CharStream input, RecognizerSharedState state) {
        super(input,state);

    }
    public String getGrammarFileName() { return "/Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g"; }

    // $ANTLR start "ATOM_NAME"
    public final void mATOM_NAME() throws RecognitionException {
        try {
            int _type = ATOM_NAME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1564:10: ( 'A' NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1564:17: 'A' NAT
            {
            match('A'); 
            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ATOM_NAME"

    // $ANTLR start "UNIV_NAME"
    public final void mUNIV_NAME() throws RecognitionException {
        try {
            int _type = UNIV_NAME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1565:10: ( 'u' NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1565:17: 'u' NAT
            {
            match('u'); 
            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "UNIV_NAME"

    // $ANTLR start "OFFSET_UNIV_NAME"
    public final void mOFFSET_UNIV_NAME() throws RecognitionException {
        try {
            int _type = OFFSET_UNIV_NAME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1566:17: ( 'u' NAT '@' NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1567:17: 'u' NAT '@' NAT
            {
            match('u'); 
            mNAT(); 
            match('@'); 
            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OFFSET_UNIV_NAME"

    // $ANTLR start "TUPLE_NAME"
    public final void mTUPLE_NAME() throws RecognitionException {
        try {
            int _type = TUPLE_NAME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1568:11: ( ( 'P' | 'T' NAT '_' ) NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1568:17: ( 'P' | 'T' NAT '_' ) NAT
            {
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1568:17: ( 'P' | 'T' NAT '_' )
            int alt1=2;
            int LA1_0 = input.LA(1);

            if ( (LA1_0=='P') ) {
                alt1=1;
            }
            else if ( (LA1_0=='T') ) {
                alt1=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("", 1, 0, input);

                throw nvae;
            }
            switch (alt1) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1568:18: 'P'
                    {
                    match('P'); 

                    }
                    break;
                case 2 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1568:24: 'T' NAT '_'
                    {
                    match('T'); 
                    mNAT(); 
                    match('_'); 

                    }
                    break;

            }

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TUPLE_NAME"

    // $ANTLR start "RELATION_NAME"
    public final void mRELATION_NAME() throws RecognitionException {
        try {
            int _type = RELATION_NAME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1569:14: ( ( 's' | 'r' | 'm' NAT '_' ) NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1569:17: ( 's' | 'r' | 'm' NAT '_' ) NAT
            {
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1569:17: ( 's' | 'r' | 'm' NAT '_' )
            int alt2=3;
            switch ( input.LA(1) ) {
            case 's':
                {
                alt2=1;
                }
                break;
            case 'r':
                {
                alt2=2;
                }
                break;
            case 'm':
                {
                alt2=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 2, 0, input);

                throw nvae;
            }

            switch (alt2) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1569:18: 's'
                    {
                    match('s'); 

                    }
                    break;
                case 2 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1569:24: 'r'
                    {
                    match('r'); 

                    }
                    break;
                case 3 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1569:30: 'm' NAT '_'
                    {
                    match('m'); 
                    mNAT(); 
                    match('_'); 

                    }
                    break;

            }

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RELATION_NAME"

    // $ANTLR start "VARIABLE_NAME"
    public final void mVARIABLE_NAME() throws RecognitionException {
        try {
            int _type = VARIABLE_NAME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:14: ( ( 'S' | 'R' | 'M' NAT '_' ) NAT ( '\\'' )? )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:17: ( 'S' | 'R' | 'M' NAT '_' ) NAT ( '\\'' )?
            {
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:17: ( 'S' | 'R' | 'M' NAT '_' )
            int alt3=3;
            switch ( input.LA(1) ) {
            case 'S':
                {
                alt3=1;
                }
                break;
            case 'R':
                {
                alt3=2;
                }
                break;
            case 'M':
                {
                alt3=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 3, 0, input);

                throw nvae;
            }

            switch (alt3) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:18: 'S'
                    {
                    match('S'); 

                    }
                    break;
                case 2 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:24: 'R'
                    {
                    match('R'); 

                    }
                    break;
                case 3 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:30: 'M' NAT '_'
                    {
                    match('M'); 
                    mNAT(); 
                    match('_'); 

                    }
                    break;

            }

            mNAT(); 
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:47: ( '\\'' )?
            int alt4=2;
            int LA4_0 = input.LA(1);

            if ( (LA4_0=='\'') ) {
                alt4=1;
            }
            switch (alt4) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1570:47: '\\''
                    {
                    match('\''); 

                    }
                    break;

            }


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "VARIABLE_NAME"

    // $ANTLR start "TUPLE_SET_REG"
    public final void mTUPLE_SET_REG() throws RecognitionException {
        try {
            int _type = TUPLE_SET_REG;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1571:14: ( '$' ( 'a' | 'p' | 't' NAT '_' ) NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1571:17: '$' ( 'a' | 'p' | 't' NAT '_' ) NAT
            {
            match('$'); 
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1571:21: ( 'a' | 'p' | 't' NAT '_' )
            int alt5=3;
            switch ( input.LA(1) ) {
            case 'a':
                {
                alt5=1;
                }
                break;
            case 'p':
                {
                alt5=2;
                }
                break;
            case 't':
                {
                alt5=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 5, 0, input);

                throw nvae;
            }

            switch (alt5) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1571:22: 'a'
                    {
                    match('a'); 

                    }
                    break;
                case 2 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1571:28: 'p'
                    {
                    match('p'); 

                    }
                    break;
                case 3 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1571:34: 't' NAT '_'
                    {
                    match('t'); 
                    mNAT(); 
                    match('_'); 

                    }
                    break;

            }

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TUPLE_SET_REG"

    // $ANTLR start "TUPLE_REG"
    public final void mTUPLE_REG() throws RecognitionException {
        try {
            int _type = TUPLE_REG;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1572:10: ( '$' ( 'A' | 'P' | 'T' NAT '_' ) NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1572:17: '$' ( 'A' | 'P' | 'T' NAT '_' ) NAT
            {
            match('$'); 
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1572:21: ( 'A' | 'P' | 'T' NAT '_' )
            int alt6=3;
            switch ( input.LA(1) ) {
            case 'A':
                {
                alt6=1;
                }
                break;
            case 'P':
                {
                alt6=2;
                }
                break;
            case 'T':
                {
                alt6=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 6, 0, input);

                throw nvae;
            }

            switch (alt6) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1572:22: 'A'
                    {
                    match('A'); 

                    }
                    break;
                case 2 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1572:28: 'P'
                    {
                    match('P'); 

                    }
                    break;
                case 3 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1572:34: 'T' NAT '_'
                    {
                    match('T'); 
                    mNAT(); 
                    match('_'); 

                    }
                    break;

            }

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TUPLE_REG"

    // $ANTLR start "FORMULA_REG"
    public final void mFORMULA_REG() throws RecognitionException {
        try {
            int _type = FORMULA_REG;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1573:12: ( '$f' NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1573:17: '$f' NAT
            {
            match("$f"); 

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FORMULA_REG"

    // $ANTLR start "REL_EXPR_REG"
    public final void mREL_EXPR_REG() throws RecognitionException {
        try {
            int _type = REL_EXPR_REG;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1574:13: ( '$e' NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1574:17: '$e' NAT
            {
            match("$e"); 

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "REL_EXPR_REG"

    // $ANTLR start "INT_EXPR_REG"
    public final void mINT_EXPR_REG() throws RecognitionException {
        try {
            int _type = INT_EXPR_REG;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1575:13: ( '$i' NAT )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1575:17: '$i' NAT
            {
            match("$i"); 

            mNAT(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "INT_EXPR_REG"

    // $ANTLR start "NUM"
    public final void mNUM() throws RecognitionException {
        try {
            int _type = NUM;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1577:4: ( ( PLUS | MINUS )? ( '0' .. '9' )+ )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1577:17: ( PLUS | MINUS )? ( '0' .. '9' )+
            {
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1577:17: ( PLUS | MINUS )?
            int alt7=2;
            int LA7_0 = input.LA(1);

            if ( (LA7_0=='+'||LA7_0=='-') ) {
                alt7=1;
            }
            switch (alt7) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:
                    {
                    if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                        input.consume();

                    }
                    else {
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        recover(mse);
                        throw mse;}


                    }
                    break;

            }

            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1577:33: ( '0' .. '9' )+
            int cnt8=0;
            loop8:
            do {
                int alt8=2;
                int LA8_0 = input.LA(1);

                if ( ((LA8_0>='0' && LA8_0<='9')) ) {
                    alt8=1;
                }


                switch (alt8) {
            	case 1 :
            	    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1577:33: '0' .. '9'
            	    {
            	    matchRange('0','9'); 

            	    }
            	    break;

            	default :
            	    if ( cnt8 >= 1 ) break loop8;
                        EarlyExitException eee =
                            new EarlyExitException(8, input);
                        throw eee;
                }
                cnt8++;
            } while (true);


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "NUM"

    // $ANTLR start "NAT"
    public final void mNAT() throws RecognitionException {
        try {
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1578:13: ( '0' | '1' .. '9' ( '0' .. '9' )* )
            int alt10=2;
            int LA10_0 = input.LA(1);

            if ( (LA10_0=='0') ) {
                alt10=1;
            }
            else if ( ((LA10_0>='1' && LA10_0<='9')) ) {
                alt10=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("", 10, 0, input);

                throw nvae;
            }
            switch (alt10) {
                case 1 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1578:17: '0'
                    {
                    match('0'); 

                    }
                    break;
                case 2 :
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1578:23: '1' .. '9' ( '0' .. '9' )*
                    {
                    matchRange('1','9'); 
                    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1578:32: ( '0' .. '9' )*
                    loop9:
                    do {
                        int alt9=2;
                        int LA9_0 = input.LA(1);

                        if ( ((LA9_0>='0' && LA9_0<='9')) ) {
                            alt9=1;
                        }


                        switch (alt9) {
                    	case 1 :
                    	    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1578:32: '0' .. '9'
                    	    {
                    	    matchRange('0','9'); 

                    	    }
                    	    break;

                    	default :
                    	    break loop9;
                        }
                    } while (true);


                    }
                    break;

            }
        }
        finally {
        }
    }
    // $ANTLR end "NAT"

    // $ANTLR start "STR_LITERAL"
    public final void mSTR_LITERAL() throws RecognitionException {
        try {
            int _type = STR_LITERAL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1579:12: ( '\"' (~ ( '\"' | '\\n' ) )* '\"' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1579:17: '\"' (~ ( '\"' | '\\n' ) )* '\"'
            {
            match('\"'); 
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1579:21: (~ ( '\"' | '\\n' ) )*
            loop11:
            do {
                int alt11=2;
                int LA11_0 = input.LA(1);

                if ( ((LA11_0>='\u0000' && LA11_0<='\t')||(LA11_0>='\u000B' && LA11_0<='!')||(LA11_0>='#' && LA11_0<='\uFFFF')) ) {
                    alt11=1;
                }


                switch (alt11) {
            	case 1 :
            	    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1579:21: ~ ( '\"' | '\\n' )
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\t')||(input.LA(1)>='\u000B' && input.LA(1)<='!')||(input.LA(1)>='#' && input.LA(1)<='\uFFFF') ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop11;
                }
            } while (true);

            match('\"'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "STR_LITERAL"

    // $ANTLR start "WHITESPACE"
    public final void mWHITESPACE() throws RecognitionException {
        try {
            int _type = WHITESPACE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1580:11: ( ( ' ' | '\\n' | '\\r' | '\\t' | '\\v' )+ )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1580:17: ( ' ' | '\\n' | '\\r' | '\\t' | '\\v' )+
            {
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1580:17: ( ' ' | '\\n' | '\\r' | '\\t' | '\\v' )+
            int cnt12=0;
            loop12:
            do {
                int alt12=2;
                int LA12_0 = input.LA(1);

                if ( ((LA12_0>='\t' && LA12_0<='\n')||LA12_0=='\r'||LA12_0==' '||LA12_0=='v') ) {
                    alt12=1;
                }


                switch (alt12) {
            	case 1 :
            	    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:
            	    {
            	    if ( (input.LA(1)>='\t' && input.LA(1)<='\n')||input.LA(1)=='\r'||input.LA(1)==' '||input.LA(1)=='v' ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    if ( cnt12 >= 1 ) break loop12;
                        EarlyExitException eee =
                            new EarlyExitException(12, input);
                        throw eee;
                }
                cnt12++;
            } while (true);

             skip(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WHITESPACE"

    // $ANTLR start "INLINE_COMMENT"
    public final void mINLINE_COMMENT() throws RecognitionException {
        try {
            int _type = INLINE_COMMENT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1581:15: ( '//' (~ ( '\\n' ) )* )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1581:17: '//' (~ ( '\\n' ) )*
            {
            match("//"); 

            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1581:22: (~ ( '\\n' ) )*
            loop13:
            do {
                int alt13=2;
                int LA13_0 = input.LA(1);

                if ( ((LA13_0>='\u0000' && LA13_0<='\t')||(LA13_0>='\u000B' && LA13_0<='\uFFFF')) ) {
                    alt13=1;
                }


                switch (alt13) {
            	case 1 :
            	    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1581:22: ~ ( '\\n' )
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\t')||(input.LA(1)>='\u000B' && input.LA(1)<='\uFFFF') ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop13;
                }
            } while (true);

             skip(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "INLINE_COMMENT"

    // $ANTLR start "BLOCK_COMMENT"
    public final void mBLOCK_COMMENT() throws RecognitionException {
        try {
            int _type = BLOCK_COMMENT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1582:14: ( '/*' ( options {greedy=false; } : . )* '*/' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1582:17: '/*' ( options {greedy=false; } : . )* '*/'
            {
            match("/*"); 

            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1582:22: ( options {greedy=false; } : . )*
            loop14:
            do {
                int alt14=2;
                int LA14_0 = input.LA(1);

                if ( (LA14_0=='*') ) {
                    int LA14_1 = input.LA(2);

                    if ( (LA14_1=='/') ) {
                        alt14=2;
                    }
                    else if ( ((LA14_1>='\u0000' && LA14_1<='.')||(LA14_1>='0' && LA14_1<='\uFFFF')) ) {
                        alt14=1;
                    }


                }
                else if ( ((LA14_0>='\u0000' && LA14_0<=')')||(LA14_0>='+' && LA14_0<='\uFFFF')) ) {
                    alt14=1;
                }


                switch (alt14) {
            	case 1 :
            	    // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1582:53: .
            	    {
            	    matchAny(); 

            	    }
            	    break;

            	default :
            	    break loop14;
                }
            } while (true);

            match("*/"); 

             skip(); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BLOCK_COMMENT"

    // $ANTLR start "AMP"
    public final void mAMP() throws RecognitionException {
        try {
            int _type = AMP;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1584:4: ( '&' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1584:17: '&'
            {
            match('&'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "AMP"

    // $ANTLR start "AND"
    public final void mAND() throws RecognitionException {
        try {
            int _type = AND;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1585:4: ( '&&' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1585:17: '&&'
            {
            match("&&"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "AND"

    // $ANTLR start "ARROW"
    public final void mARROW() throws RecognitionException {
        try {
            int _type = ARROW;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1586:6: ( '->' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1586:17: '->'
            {
            match("->"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ARROW"

    // $ANTLR start "COLON_EQ"
    public final void mCOLON_EQ() throws RecognitionException {
        try {
            int _type = COLON_EQ;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1587:9: ( ':=' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1587:17: ':='
            {
            match(":="); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COLON_EQ"

    // $ANTLR start "BAR"
    public final void mBAR() throws RecognitionException {
        try {
            int _type = BAR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1588:4: ( '|' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1588:17: '|'
            {
            match('|'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BAR"

    // $ANTLR start "BRACE_LEFT"
    public final void mBRACE_LEFT() throws RecognitionException {
        try {
            int _type = BRACE_LEFT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1589:11: ( '{' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1589:17: '{'
            {
            match('{'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BRACE_LEFT"

    // $ANTLR start "BRACE_RIGHT"
    public final void mBRACE_RIGHT() throws RecognitionException {
        try {
            int _type = BRACE_RIGHT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1590:12: ( '}' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1590:17: '}'
            {
            match('}'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BRACE_RIGHT"

    // $ANTLR start "BRACKET_LEFT"
    public final void mBRACKET_LEFT() throws RecognitionException {
        try {
            int _type = BRACKET_LEFT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1591:13: ( '[' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1591:17: '['
            {
            match('['); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BRACKET_LEFT"

    // $ANTLR start "BRACKET_RIGHT"
    public final void mBRACKET_RIGHT() throws RecognitionException {
        try {
            int _type = BRACKET_RIGHT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1592:14: ( ']' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1592:17: ']'
            {
            match(']'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BRACKET_RIGHT"

    // $ANTLR start "COLON"
    public final void mCOLON() throws RecognitionException {
        try {
            int _type = COLON;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1593:6: ( ':' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1593:17: ':'
            {
            match(':'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COLON"

    // $ANTLR start "COMMA"
    public final void mCOMMA() throws RecognitionException {
        try {
            int _type = COMMA;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1594:6: ( ',' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1594:17: ','
            {
            match(','); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COMMA"

    // $ANTLR start "DIVIDE"
    public final void mDIVIDE() throws RecognitionException {
        try {
            int _type = DIVIDE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1595:7: ( '/' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1595:17: '/'
            {
            match('/'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "DIVIDE"

    // $ANTLR start "DOT"
    public final void mDOT() throws RecognitionException {
        try {
            int _type = DOT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1596:4: ( '.' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1596:17: '.'
            {
            match('.'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "DOT"

    // $ANTLR start "DOT_DOT"
    public final void mDOT_DOT() throws RecognitionException {
        try {
            int _type = DOT_DOT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1597:8: ( '..' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1597:17: '..'
            {
            match(".."); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "DOT_DOT"

    // $ANTLR start "EQ"
    public final void mEQ() throws RecognitionException {
        try {
            int _type = EQ;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1598:3: ( '=' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1598:17: '='
            {
            match('='); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "EQ"

    // $ANTLR start "GE"
    public final void mGE() throws RecognitionException {
        try {
            int _type = GE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1599:3: ( '>=' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1599:17: '>='
            {
            match(">="); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "GE"

    // $ANTLR start "GT"
    public final void mGT() throws RecognitionException {
        try {
            int _type = GT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1600:3: ( '>' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1600:17: '>'
            {
            match('>'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "GT"

    // $ANTLR start "HASH"
    public final void mHASH() throws RecognitionException {
        try {
            int _type = HASH;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1601:5: ( '#' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1601:17: '#'
            {
            match('#'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "HASH"

    // $ANTLR start "HAT"
    public final void mHAT() throws RecognitionException {
        try {
            int _type = HAT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1602:4: ( '^' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1602:17: '^'
            {
            match('^'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "HAT"

    // $ANTLR start "IFF"
    public final void mIFF() throws RecognitionException {
        try {
            int _type = IFF;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1603:4: ( '<=>' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1603:17: '<=>'
            {
            match("<=>"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IFF"

    // $ANTLR start "IFNO"
    public final void mIFNO() throws RecognitionException {
        try {
            int _type = IFNO;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1604:5: ( '\\\\' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1604:17: '\\\\'
            {
            match('\\'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IFNO"

    // $ANTLR start "IMPLIES"
    public final void mIMPLIES() throws RecognitionException {
        try {
            int _type = IMPLIES;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1605:8: ( '=>' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1605:17: '=>'
            {
            match("=>"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IMPLIES"

    // $ANTLR start "LT"
    public final void mLT() throws RecognitionException {
        try {
            int _type = LT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1606:3: ( '<' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1606:17: '<'
            {
            match('<'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LT"

    // $ANTLR start "LE"
    public final void mLE() throws RecognitionException {
        try {
            int _type = LE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1607:3: ( '<=' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1607:17: '<='
            {
            match("<="); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LE"

    // $ANTLR start "MINUS"
    public final void mMINUS() throws RecognitionException {
        try {
            int _type = MINUS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1608:7: ( '-' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1608:17: '-'
            {
            match('-'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "MINUS"

    // $ANTLR start "MODULO"
    public final void mMODULO() throws RecognitionException {
        try {
            int _type = MODULO;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1609:7: ( '%' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1609:17: '%'
            {
            match('%'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "MODULO"

    // $ANTLR start "NOT"
    public final void mNOT() throws RecognitionException {
        try {
            int _type = NOT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1610:4: ( '!' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1610:17: '!'
            {
            match('!'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "NOT"

    // $ANTLR start "OVERRIDE"
    public final void mOVERRIDE() throws RecognitionException {
        try {
            int _type = OVERRIDE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1611:10: ( '++' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1611:17: '++'
            {
            match("++"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OVERRIDE"

    // $ANTLR start "OR"
    public final void mOR() throws RecognitionException {
        try {
            int _type = OR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1612:3: ( '||' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1612:17: '||'
            {
            match("||"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OR"

    // $ANTLR start "PAREN_LEFT"
    public final void mPAREN_LEFT() throws RecognitionException {
        try {
            int _type = PAREN_LEFT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1613:11: ( '(' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1613:17: '('
            {
            match('('); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PAREN_LEFT"

    // $ANTLR start "PAREN_RIGHT"
    public final void mPAREN_RIGHT() throws RecognitionException {
        try {
            int _type = PAREN_RIGHT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1614:12: ( ')' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1614:17: ')'
            {
            match(')'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PAREN_RIGHT"

    // $ANTLR start "PLUS"
    public final void mPLUS() throws RecognitionException {
        try {
            int _type = PLUS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1615:5: ( '+' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1615:17: '+'
            {
            match('+'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PLUS"

    // $ANTLR start "SEMICOLON"
    public final void mSEMICOLON() throws RecognitionException {
        try {
            int _type = SEMICOLON;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1616:10: ( ';' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1616:17: ';'
            {
            match(';'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SEMICOLON"

    // $ANTLR start "SHA"
    public final void mSHA() throws RecognitionException {
        try {
            int _type = SHA;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1617:4: ( '>>' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1617:17: '>>'
            {
            match(">>"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SHA"

    // $ANTLR start "SHL"
    public final void mSHL() throws RecognitionException {
        try {
            int _type = SHL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1618:4: ( '<<' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1618:17: '<<'
            {
            match("<<"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SHL"

    // $ANTLR start "SHR"
    public final void mSHR() throws RecognitionException {
        try {
            int _type = SHR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1619:4: ( '>>>' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1619:17: '>>>'
            {
            match(">>>"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SHR"

    // $ANTLR start "STAR"
    public final void mSTAR() throws RecognitionException {
        try {
            int _type = STAR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1620:5: ( '*' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1620:17: '*'
            {
            match('*'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "STAR"

    // $ANTLR start "TILDE"
    public final void mTILDE() throws RecognitionException {
        try {
            int _type = TILDE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1621:6: ( '~' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1621:17: '~'
            {
            match('~'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TILDE"

    // $ANTLR start "ABS"
    public final void mABS() throws RecognitionException {
        try {
            int _type = ABS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1623:4: ( 'abs' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1623:17: 'abs'
            {
            match("abs"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ABS"

    // $ANTLR start "ACYCLIC"
    public final void mACYCLIC() throws RecognitionException {
        try {
            int _type = ACYCLIC;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1624:8: ( 'ACYCLIC' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1624:17: 'ACYCLIC'
            {
            match("ACYCLIC"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ACYCLIC"

    // $ANTLR start "ALL"
    public final void mALL() throws RecognitionException {
        try {
            int _type = ALL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1625:4: ( 'all' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1625:17: 'all'
            {
            match("all"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ALL"

    // $ANTLR start "BITS"
    public final void mBITS() throws RecognitionException {
        try {
            int _type = BITS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1626:5: ( 'Bits' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1626:17: 'Bits'
            {
            match("Bits"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BITS"

    // $ANTLR start "BIT_WIDTH"
    public final void mBIT_WIDTH() throws RecognitionException {
        try {
            int _type = BIT_WIDTH;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1627:10: ( 'bit_width' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1627:17: 'bit_width'
            {
            match("bit_width"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BIT_WIDTH"

    // $ANTLR start "BOUNDS"
    public final void mBOUNDS() throws RecognitionException {
        try {
            int _type = BOUNDS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1628:7: ( 'bounds' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1628:17: 'bounds'
            {
            match("bounds"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BOUNDS"

    // $ANTLR start "ELSE"
    public final void mELSE() throws RecognitionException {
        try {
            int _type = ELSE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1629:5: ( 'else' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1629:17: 'else'
            {
            match("else"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ELSE"

    // $ANTLR start "FALSE"
    public final void mFALSE() throws RecognitionException {
        try {
            int _type = FALSE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1630:6: ( 'false' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1630:17: 'false'
            {
            match("false"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FALSE"

    // $ANTLR start "FLATTEN"
    public final void mFLATTEN() throws RecognitionException {
        try {
            int _type = FLATTEN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1631:8: ( 'flatten' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1631:17: 'flatten'
            {
            match("flatten"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FLATTEN"

    // $ANTLR start "FUNCTION"
    public final void mFUNCTION() throws RecognitionException {
        try {
            int _type = FUNCTION;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1632:9: ( 'FUNCTION' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1632:17: 'FUNCTION'
            {
            match("FUNCTION"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FUNCTION"

    // $ANTLR start "IDEN"
    public final void mIDEN() throws RecognitionException {
        try {
            int _type = IDEN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1633:5: ( 'iden' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1633:17: 'iden'
            {
            match("iden"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IDEN"

    // $ANTLR start "IF"
    public final void mIF() throws RecognitionException {
        try {
            int _type = IF;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1634:3: ( 'if' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1634:17: 'if'
            {
            match("if"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IF"

    // $ANTLR start "IN"
    public final void mIN() throws RecognitionException {
        try {
            int _type = IN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1635:3: ( 'in' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1635:17: 'in'
            {
            match("in"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IN"

    // $ANTLR start "INT"
    public final void mINT() throws RecognitionException {
        try {
            int _type = INT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1636:4: ( 'Int' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1636:17: 'Int'
            {
            match("Int"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "INT"

    // $ANTLR start "INT_BOUNDS"
    public final void mINT_BOUNDS() throws RecognitionException {
        try {
            int _type = INT_BOUNDS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1637:11: ( 'int_bounds' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1637:17: 'int_bounds'
            {
            match("int_bounds"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "INT_BOUNDS"

    // $ANTLR start "INTS"
    public final void mINTS() throws RecognitionException {
        try {
            int _type = INTS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1638:5: ( 'ints' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1638:17: 'ints'
            {
            match("ints"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "INTS"

    // $ANTLR start "LET"
    public final void mLET() throws RecognitionException {
        try {
            int _type = LET;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1639:4: ( 'let' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1639:17: 'let'
            {
            match("let"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LET"

    // $ANTLR start "LONE"
    public final void mLONE() throws RecognitionException {
        try {
            int _type = LONE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1640:5: ( 'lone' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1640:17: 'lone'
            {
            match("lone"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LONE"

    // $ANTLR start "NO"
    public final void mNO() throws RecognitionException {
        try {
            int _type = NO;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1641:3: ( 'no' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1641:17: 'no'
            {
            match("no"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "NO"

    // $ANTLR start "NONE"
    public final void mNONE() throws RecognitionException {
        try {
            int _type = NONE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1642:5: ( 'none' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1642:17: 'none'
            {
            match("none"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "NONE"

    // $ANTLR start "ONE"
    public final void mONE() throws RecognitionException {
        try {
            int _type = ONE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1643:4: ( 'one' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1643:17: 'one'
            {
            match("one"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ONE"

    // $ANTLR start "RELATION"
    public final void mRELATION() throws RecognitionException {
        try {
            int _type = RELATION;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1644:9: ( 'relation' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1644:17: 'relation'
            {
            match("relation"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RELATION"

    // $ANTLR start "SET"
    public final void mSET() throws RecognitionException {
        try {
            int _type = SET;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1645:4: ( 'set' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1645:17: 'set'
            {
            match("set"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SET"

    // $ANTLR start "SGN"
    public final void mSGN() throws RecognitionException {
        try {
            int _type = SGN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1646:4: ( 'sgn' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1646:17: 'sgn'
            {
            match("sgn"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SGN"

    // $ANTLR start "SHARING"
    public final void mSHARING() throws RecognitionException {
        try {
            int _type = SHARING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1647:8: ( 'sharing' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1647:17: 'sharing'
            {
            match("sharing"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SHARING"

    // $ANTLR start "SKOLEM_DEPTH"
    public final void mSKOLEM_DEPTH() throws RecognitionException {
        try {
            int _type = SKOLEM_DEPTH;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1648:13: ( 'skolem_depth' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1648:17: 'skolem_depth'
            {
            match("skolem_depth"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SKOLEM_DEPTH"

    // $ANTLR start "SOLVE"
    public final void mSOLVE() throws RecognitionException {
        try {
            int _type = SOLVE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1649:6: ( 'solve' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1649:17: 'solve'
            {
            match("solve"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SOLVE"

    // $ANTLR start "SOLVER"
    public final void mSOLVER() throws RecognitionException {
        try {
            int _type = SOLVER;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1650:7: ( 'solver' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1650:17: 'solver'
            {
            match("solver"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SOLVER"

    // $ANTLR start "SOME"
    public final void mSOME() throws RecognitionException {
        try {
            int _type = SOME;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1651:5: ( 'some' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1651:17: 'some'
            {
            match("some"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SOME"

    // $ANTLR start "SUM"
    public final void mSUM() throws RecognitionException {
        try {
            int _type = SUM;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1652:4: ( 'sum' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1652:17: 'sum'
            {
            match("sum"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SUM"

    // $ANTLR start "SYMMETRY_BREAKING"
    public final void mSYMMETRY_BREAKING() throws RecognitionException {
        try {
            int _type = SYMMETRY_BREAKING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1653:18: ( 'symmetry_breaking' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1654:17: 'symmetry_breaking'
            {
            match("symmetry_breaking"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SYMMETRY_BREAKING"

    // $ANTLR start "THEN"
    public final void mTHEN() throws RecognitionException {
        try {
            int _type = THEN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1655:5: ( 'then' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1655:17: 'then'
            {
            match("then"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "THEN"

    // $ANTLR start "TOTAL_ORDERING"
    public final void mTOTAL_ORDERING() throws RecognitionException {
        try {
            int _type = TOTAL_ORDERING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1656:15: ( 'TOTAL_ORDERING' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1656:17: 'TOTAL_ORDERING'
            {
            match("TOTAL_ORDERING"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TOTAL_ORDERING"

    // $ANTLR start "TRUE"
    public final void mTRUE() throws RecognitionException {
        try {
            int _type = TRUE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1657:5: ( 'true' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1657:17: 'true'
            {
            match("true"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TRUE"

    // $ANTLR start "UNIV"
    public final void mUNIV() throws RecognitionException {
        try {
            int _type = UNIV;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1658:5: ( 'univ' )
            // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1658:17: 'univ'
            {
            match("univ"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "UNIV"

    public void mTokens() throws RecognitionException {
        // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:8: ( ATOM_NAME | UNIV_NAME | OFFSET_UNIV_NAME | TUPLE_NAME | RELATION_NAME | VARIABLE_NAME | TUPLE_SET_REG | TUPLE_REG | FORMULA_REG | REL_EXPR_REG | INT_EXPR_REG | NUM | STR_LITERAL | WHITESPACE | INLINE_COMMENT | BLOCK_COMMENT | AMP | AND | ARROW | COLON_EQ | BAR | BRACE_LEFT | BRACE_RIGHT | BRACKET_LEFT | BRACKET_RIGHT | COLON | COMMA | DIVIDE | DOT | DOT_DOT | EQ | GE | GT | HASH | HAT | IFF | IFNO | IMPLIES | LT | LE | MINUS | MODULO | NOT | OVERRIDE | OR | PAREN_LEFT | PAREN_RIGHT | PLUS | SEMICOLON | SHA | SHL | SHR | STAR | TILDE | ABS | ACYCLIC | ALL | BITS | BIT_WIDTH | BOUNDS | ELSE | FALSE | FLATTEN | FUNCTION | IDEN | IF | IN | INT | INT_BOUNDS | INTS | LET | LONE | NO | NONE | ONE | RELATION | SET | SGN | SHARING | SKOLEM_DEPTH | SOLVE | SOLVER | SOME | SUM | SYMMETRY_BREAKING | THEN | TOTAL_ORDERING | TRUE | UNIV )
        int alt15=89;
        alt15 = dfa15.predict(input);
        switch (alt15) {
            case 1 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:10: ATOM_NAME
                {
                mATOM_NAME(); 

                }
                break;
            case 2 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:20: UNIV_NAME
                {
                mUNIV_NAME(); 

                }
                break;
            case 3 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:30: OFFSET_UNIV_NAME
                {
                mOFFSET_UNIV_NAME(); 

                }
                break;
            case 4 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:47: TUPLE_NAME
                {
                mTUPLE_NAME(); 

                }
                break;
            case 5 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:58: RELATION_NAME
                {
                mRELATION_NAME(); 

                }
                break;
            case 6 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:72: VARIABLE_NAME
                {
                mVARIABLE_NAME(); 

                }
                break;
            case 7 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:86: TUPLE_SET_REG
                {
                mTUPLE_SET_REG(); 

                }
                break;
            case 8 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:100: TUPLE_REG
                {
                mTUPLE_REG(); 

                }
                break;
            case 9 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:110: FORMULA_REG
                {
                mFORMULA_REG(); 

                }
                break;
            case 10 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:122: REL_EXPR_REG
                {
                mREL_EXPR_REG(); 

                }
                break;
            case 11 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:135: INT_EXPR_REG
                {
                mINT_EXPR_REG(); 

                }
                break;
            case 12 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:148: NUM
                {
                mNUM(); 

                }
                break;
            case 13 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:152: STR_LITERAL
                {
                mSTR_LITERAL(); 

                }
                break;
            case 14 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:164: WHITESPACE
                {
                mWHITESPACE(); 

                }
                break;
            case 15 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:175: INLINE_COMMENT
                {
                mINLINE_COMMENT(); 

                }
                break;
            case 16 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:190: BLOCK_COMMENT
                {
                mBLOCK_COMMENT(); 

                }
                break;
            case 17 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:204: AMP
                {
                mAMP(); 

                }
                break;
            case 18 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:208: AND
                {
                mAND(); 

                }
                break;
            case 19 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:212: ARROW
                {
                mARROW(); 

                }
                break;
            case 20 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:218: COLON_EQ
                {
                mCOLON_EQ(); 

                }
                break;
            case 21 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:227: BAR
                {
                mBAR(); 

                }
                break;
            case 22 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:231: BRACE_LEFT
                {
                mBRACE_LEFT(); 

                }
                break;
            case 23 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:242: BRACE_RIGHT
                {
                mBRACE_RIGHT(); 

                }
                break;
            case 24 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:254: BRACKET_LEFT
                {
                mBRACKET_LEFT(); 

                }
                break;
            case 25 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:267: BRACKET_RIGHT
                {
                mBRACKET_RIGHT(); 

                }
                break;
            case 26 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:281: COLON
                {
                mCOLON(); 

                }
                break;
            case 27 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:287: COMMA
                {
                mCOMMA(); 

                }
                break;
            case 28 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:293: DIVIDE
                {
                mDIVIDE(); 

                }
                break;
            case 29 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:300: DOT
                {
                mDOT(); 

                }
                break;
            case 30 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:304: DOT_DOT
                {
                mDOT_DOT(); 

                }
                break;
            case 31 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:312: EQ
                {
                mEQ(); 

                }
                break;
            case 32 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:315: GE
                {
                mGE(); 

                }
                break;
            case 33 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:318: GT
                {
                mGT(); 

                }
                break;
            case 34 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:321: HASH
                {
                mHASH(); 

                }
                break;
            case 35 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:326: HAT
                {
                mHAT(); 

                }
                break;
            case 36 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:330: IFF
                {
                mIFF(); 

                }
                break;
            case 37 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:334: IFNO
                {
                mIFNO(); 

                }
                break;
            case 38 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:339: IMPLIES
                {
                mIMPLIES(); 

                }
                break;
            case 39 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:347: LT
                {
                mLT(); 

                }
                break;
            case 40 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:350: LE
                {
                mLE(); 

                }
                break;
            case 41 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:353: MINUS
                {
                mMINUS(); 

                }
                break;
            case 42 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:359: MODULO
                {
                mMODULO(); 

                }
                break;
            case 43 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:366: NOT
                {
                mNOT(); 

                }
                break;
            case 44 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:370: OVERRIDE
                {
                mOVERRIDE(); 

                }
                break;
            case 45 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:379: OR
                {
                mOR(); 

                }
                break;
            case 46 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:382: PAREN_LEFT
                {
                mPAREN_LEFT(); 

                }
                break;
            case 47 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:393: PAREN_RIGHT
                {
                mPAREN_RIGHT(); 

                }
                break;
            case 48 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:405: PLUS
                {
                mPLUS(); 

                }
                break;
            case 49 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:410: SEMICOLON
                {
                mSEMICOLON(); 

                }
                break;
            case 50 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:420: SHA
                {
                mSHA(); 

                }
                break;
            case 51 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:424: SHL
                {
                mSHL(); 

                }
                break;
            case 52 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:428: SHR
                {
                mSHR(); 

                }
                break;
            case 53 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:432: STAR
                {
                mSTAR(); 

                }
                break;
            case 54 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:437: TILDE
                {
                mTILDE(); 

                }
                break;
            case 55 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:443: ABS
                {
                mABS(); 

                }
                break;
            case 56 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:447: ACYCLIC
                {
                mACYCLIC(); 

                }
                break;
            case 57 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:455: ALL
                {
                mALL(); 

                }
                break;
            case 58 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:459: BITS
                {
                mBITS(); 

                }
                break;
            case 59 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:464: BIT_WIDTH
                {
                mBIT_WIDTH(); 

                }
                break;
            case 60 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:474: BOUNDS
                {
                mBOUNDS(); 

                }
                break;
            case 61 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:481: ELSE
                {
                mELSE(); 

                }
                break;
            case 62 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:486: FALSE
                {
                mFALSE(); 

                }
                break;
            case 63 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:492: FLATTEN
                {
                mFLATTEN(); 

                }
                break;
            case 64 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:500: FUNCTION
                {
                mFUNCTION(); 

                }
                break;
            case 65 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:509: IDEN
                {
                mIDEN(); 

                }
                break;
            case 66 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:514: IF
                {
                mIF(); 

                }
                break;
            case 67 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:517: IN
                {
                mIN(); 

                }
                break;
            case 68 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:520: INT
                {
                mINT(); 

                }
                break;
            case 69 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:524: INT_BOUNDS
                {
                mINT_BOUNDS(); 

                }
                break;
            case 70 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:535: INTS
                {
                mINTS(); 

                }
                break;
            case 71 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:540: LET
                {
                mLET(); 

                }
                break;
            case 72 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:544: LONE
                {
                mLONE(); 

                }
                break;
            case 73 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:549: NO
                {
                mNO(); 

                }
                break;
            case 74 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:552: NONE
                {
                mNONE(); 

                }
                break;
            case 75 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:557: ONE
                {
                mONE(); 

                }
                break;
            case 76 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:561: RELATION
                {
                mRELATION(); 

                }
                break;
            case 77 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:570: SET
                {
                mSET(); 

                }
                break;
            case 78 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:574: SGN
                {
                mSGN(); 

                }
                break;
            case 79 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:578: SHARING
                {
                mSHARING(); 

                }
                break;
            case 80 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:586: SKOLEM_DEPTH
                {
                mSKOLEM_DEPTH(); 

                }
                break;
            case 81 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:599: SOLVE
                {
                mSOLVE(); 

                }
                break;
            case 82 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:605: SOLVER
                {
                mSOLVER(); 

                }
                break;
            case 83 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:612: SOME
                {
                mSOME(); 

                }
                break;
            case 84 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:617: SUM
                {
                mSUM(); 

                }
                break;
            case 85 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:621: SYMMETRY_BREAKING
                {
                mSYMMETRY_BREAKING(); 

                }
                break;
            case 86 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:639: THEN
                {
                mTHEN(); 

                }
                break;
            case 87 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:644: TOTAL_ORDERING
                {
                mTOTAL_ORDERING(); 

                }
                break;
            case 88 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:659: TRUE
                {
                mTRUE(); 

                }
                break;
            case 89 :
                // /Users/blanchet/tum/nitpick/Kodkodi/src/Kodkodi.g:1:664: UNIV
                {
                mUNIV(); 

                }
                break;

        }

    }


    protected DFA15 dfa15 = new DFA15(this);
    static final String DFA15_eotS =
        "\12\uffff\1\106\3\uffff\1\111\1\113\1\115\1\117\1\121\5\uffff\1"+
        "\123\1\125\1\130\2\uffff\1\133\27\uffff\2\152\40\uffff\1\160\1\uffff"+
        "\1\162\12\uffff\1\164\2\uffff\1\166\4\uffff\1\152\15\uffff\1\174"+
        "\2\uffff";
    static final String DFA15_eofS =
        "\175\uffff";
    static final String DFA15_minS =
        "\1\11\2\60\1\uffff\3\60\2\uffff\1\101\1\60\3\uffff\1\52\1\46\1\53"+
        "\1\75\1\174\5\uffff\1\56\1\76\1\75\2\uffff\1\74\10\uffff\1\142\1"+
        "\uffff\1\151\1\uffff\1\141\1\uffff\1\144\1\uffff\1\145\1\157\1\uffff"+
        "\1\150\3\uffff\1\100\1\60\5\uffff\1\154\32\uffff\1\76\1\uffff\1"+
        "\76\12\uffff\1\164\2\uffff\1\156\4\uffff\1\60\1\166\5\uffff\1\137"+
        "\3\uffff\1\145\2\uffff\1\162\2\uffff";
    static final String DFA15_maxS =
        "\1\176\1\103\1\156\1\uffff\1\117\1\171\1\145\2\uffff\1\164\1\76"+
        "\3\uffff\1\57\1\46\1\71\1\75\1\174\5\uffff\1\56\2\76\2\uffff\1\75"+
        "\10\uffff\1\154\1\uffff\1\157\1\uffff\1\154\1\uffff\1\156\1\uffff"+
        "\2\157\1\uffff\1\162\3\uffff\2\100\5\uffff\1\155\32\uffff\1\76\1"+
        "\uffff\1\76\12\uffff\1\164\2\uffff\1\156\4\uffff\1\100\1\166\5\uffff"+
        "\1\163\3\uffff\1\145\2\uffff\1\162\2\uffff";
    static final String DFA15_acceptS =
        "\3\uffff\1\4\3\uffff\1\5\1\6\2\uffff\1\14\1\15\1\16\5\uffff\1\26"+
        "\1\27\1\30\1\31\1\33\3\uffff\1\42\1\43\1\uffff\1\45\1\52\1\53\1"+
        "\56\1\57\1\61\1\65\1\66\1\uffff\1\72\1\uffff\1\75\1\uffff\1\100"+
        "\1\uffff\1\104\2\uffff\1\113\1\uffff\1\70\1\1\1\131\2\uffff\1\127"+
        "\1\115\1\116\1\117\1\120\1\uffff\1\124\1\125\1\114\1\11\1\12\1\13"+
        "\1\10\1\7\1\23\1\51\1\17\1\20\1\34\1\22\1\21\1\54\1\60\1\24\1\32"+
        "\1\55\1\25\1\36\1\35\1\46\1\37\1\40\1\uffff\1\41\1\uffff\1\63\1"+
        "\47\1\67\1\71\1\73\1\74\1\76\1\77\1\101\1\102\1\uffff\1\107\1\110"+
        "\1\uffff\1\126\1\130\1\2\1\3\2\uffff\1\123\1\64\1\62\1\44\1\50\1"+
        "\uffff\1\103\1\112\1\111\1\uffff\1\105\1\106\1\uffff\1\122\1\121";
    static final String DFA15_specialS =
        "\175\uffff}>";
    static final String[] DFA15_transitionS = {
            "\2\15\2\uffff\1\15\22\uffff\1\15\1\40\1\14\1\33\1\11\1\37\1"+
            "\17\1\uffff\1\41\1\42\1\44\1\20\1\27\1\12\1\30\1\16\12\13\1"+
            "\21\1\43\1\35\1\31\1\32\2\uffff\1\1\1\47\3\uffff\1\53\2\uffff"+
            "\1\55\3\uffff\1\10\2\uffff\1\3\1\uffff\2\10\1\4\6\uffff\1\25"+
            "\1\36\1\26\1\34\2\uffff\1\46\1\50\2\uffff\1\51\1\52\2\uffff"+
            "\1\54\2\uffff\1\56\1\7\1\57\1\60\2\uffff\1\6\1\5\1\61\1\2\1"+
            "\15\4\uffff\1\23\1\22\1\24\1\45",
            "\12\63\11\uffff\1\62",
            "\1\65\11\66\64\uffff\1\64",
            "",
            "\12\3\25\uffff\1\67",
            "\12\7\53\uffff\1\70\1\uffff\1\71\1\72\2\uffff\1\73\3\uffff"+
            "\1\74\5\uffff\1\75\3\uffff\1\76",
            "\12\7\53\uffff\1\77",
            "",
            "",
            "\1\103\16\uffff\1\103\3\uffff\1\103\14\uffff\1\104\3\uffff"+
            "\1\101\1\100\2\uffff\1\102\6\uffff\1\104\3\uffff\1\104",
            "\12\13\4\uffff\1\105",
            "",
            "",
            "",
            "\1\110\4\uffff\1\107",
            "\1\112",
            "\1\114\4\uffff\12\13",
            "\1\116",
            "\1\120",
            "",
            "",
            "",
            "",
            "",
            "\1\122",
            "\1\124",
            "\1\126\1\127",
            "",
            "",
            "\1\132\1\131",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\134\11\uffff\1\135",
            "",
            "\1\136\5\uffff\1\137",
            "",
            "\1\140\12\uffff\1\141",
            "",
            "\1\142\1\uffff\1\143\7\uffff\1\144",
            "",
            "\1\145\11\uffff\1\146",
            "\1\147",
            "",
            "\1\150\11\uffff\1\151",
            "",
            "",
            "",
            "\1\153",
            "\12\154\6\uffff\1\153",
            "",
            "",
            "",
            "",
            "",
            "\1\155\1\156",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\157",
            "",
            "\1\161",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\163",
            "",
            "",
            "\1\165",
            "",
            "",
            "",
            "",
            "\12\154\6\uffff\1\153",
            "\1\167",
            "",
            "",
            "",
            "",
            "",
            "\1\170\23\uffff\1\171",
            "",
            "",
            "",
            "\1\172",
            "",
            "",
            "\1\173",
            "",
            ""
    };

    static final short[] DFA15_eot = DFA.unpackEncodedString(DFA15_eotS);
    static final short[] DFA15_eof = DFA.unpackEncodedString(DFA15_eofS);
    static final char[] DFA15_min = DFA.unpackEncodedStringToUnsignedChars(DFA15_minS);
    static final char[] DFA15_max = DFA.unpackEncodedStringToUnsignedChars(DFA15_maxS);
    static final short[] DFA15_accept = DFA.unpackEncodedString(DFA15_acceptS);
    static final short[] DFA15_special = DFA.unpackEncodedString(DFA15_specialS);
    static final short[][] DFA15_transition;

    static {
        int numStates = DFA15_transitionS.length;
        DFA15_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA15_transition[i] = DFA.unpackEncodedString(DFA15_transitionS[i]);
        }
    }

    class DFA15 extends DFA {

        public DFA15(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 15;
            this.eot = DFA15_eot;
            this.eof = DFA15_eof;
            this.min = DFA15_min;
            this.max = DFA15_max;
            this.accept = DFA15_accept;
            this.special = DFA15_special;
            this.transition = DFA15_transition;
        }
        public String getDescription() {
            return "1:1: Tokens : ( ATOM_NAME | UNIV_NAME | OFFSET_UNIV_NAME | TUPLE_NAME | RELATION_NAME | VARIABLE_NAME | TUPLE_SET_REG | TUPLE_REG | FORMULA_REG | REL_EXPR_REG | INT_EXPR_REG | NUM | STR_LITERAL | WHITESPACE | INLINE_COMMENT | BLOCK_COMMENT | AMP | AND | ARROW | COLON_EQ | BAR | BRACE_LEFT | BRACE_RIGHT | BRACKET_LEFT | BRACKET_RIGHT | COLON | COMMA | DIVIDE | DOT | DOT_DOT | EQ | GE | GT | HASH | HAT | IFF | IFNO | IMPLIES | LT | LE | MINUS | MODULO | NOT | OVERRIDE | OR | PAREN_LEFT | PAREN_RIGHT | PLUS | SEMICOLON | SHA | SHL | SHR | STAR | TILDE | ABS | ACYCLIC | ALL | BITS | BIT_WIDTH | BOUNDS | ELSE | FALSE | FLATTEN | FUNCTION | IDEN | IF | IN | INT | INT_BOUNDS | INTS | LET | LONE | NO | NONE | ONE | RELATION | SET | SGN | SHARING | SKOLEM_DEPTH | SOLVE | SOLVER | SOME | SUM | SYMMETRY_BREAKING | THEN | TOTAL_ORDERING | TRUE | UNIV );";
        }
    }
 

}