/*
    Title:      Kodkodi.java
    Author:     Jasmin Blanchette, TU Muenchen
    License:    See COPYRIGHT for details.
*/

package de.tum.in.isabelle.Kodkodi;

import java.io.IOException;
import java.io.InputStream;
import java.util.Timer;
import java.util.TimerTask;
import de.tum.in.isabelle.Kodkodi.KodkodiLexer;
import de.tum.in.isabelle.Kodkodi.KodkodiParser;
import org.antlr.runtime.ANTLRInputStream;
import org.antlr.runtime.Lexer;
import org.antlr.runtime.RecognitionException;

public final class Kodkodi
{
/*
    private static final int DEFAULT_PORT = 9128;
*/

    private static final class ExitTask extends TimerTask {
        public void run () {
            System.err.println("Ran out of time");
            System.exit(2);
        }
    }

    private static void printVersion() {
        System.out.println("Kodkodi version 1.1.4 (17 Mar 2009)");
    }

    private static void printUsageAndExit(int code) {
        printVersion();
        (code == 0 ? System.out : System.err).println(
            "Usage: kodkodi [options]\n" +
            "options:\n" +
            "  -help               Show usage and exit\n" +
            "  -version            Show version number and exit\n" +
            "  -verbose            Produce more output\n" +
            "  -exit-on-success    Exit on the first successful 'solve' " +
            "directive\n" +
            "  -clean-up-inst      Remove trivial parts of instance from " +
            "output\n" +
            "  -max-msecs <num>    Maximum running time in milliseconds\n" +
            "  -max-threads <num>  Maximum number of simultaneous threads " +
            "(default: " + Runtime.getRuntime().availableProcessors()  + ")");
/*
            "  -server           Run as TCP server\n" +
            "  -port <number>    Listen to specified port (default: " +
            DEFAULT_PORT + ")\n"
*/
        System.exit(code);
    }

    public static void main(String[] args) {
        boolean verbose = false;
        boolean exitOnSuccess = false;
        boolean cleanUpInst = false;
        int maxMsecs = 0;
        int maxThreads = Runtime.getRuntime().availableProcessors();
/*
        boolean server = false;
        int port = DEFAULT_PORT;
*/

        try {
            int i = 0;
            while (i < args.length) {
                if (args[i].equals("-help")) {
                    printUsageAndExit(0);
                } else if (args[i].equals("-version")) {
                    printVersion();
                    System.exit(0);
                } else if (args[i].equals("-verbose")) {
                    verbose = true;
                } else if (args[i].equals("-exit-on-success")) {
                    exitOnSuccess = true;
                } else if (args[i].equals("-clean-up-inst")) {
                    cleanUpInst = true;
                } else if (args[i].equals("-max-msecs")) {
                    try {
                        ++i;
                        maxMsecs = Integer.parseInt(args[i]);
                    } catch (IndexOutOfBoundsException except) {
                        printUsageAndExit(1);
                    } catch (NumberFormatException except) {
                        printUsageAndExit(1);
                    }
                } else if (args[i].equals("-max-threads")) {
                    try {
                        ++i;
                        maxThreads = Integer.parseInt(args[i]);
                    } catch (IndexOutOfBoundsException except) {
                        printUsageAndExit(1);
                    } catch (NumberFormatException except) {
                        printUsageAndExit(1);
                    }
/*
                } else if (args[i].equals("-server")) {
                    server = true;
                } else if (args[i].equals("-port")) {
                    try {
                        ++i;
                        port = Integer.parseInt(args[i]);
                    } catch (IndexOutOfBoundsException except) {
                        printUsageAndExit(1);
                    } catch (NumberFormatException except) {
                        printUsageAndExit(1);
                    }
*/
                } else {
                    printUsageAndExit(1);
                }
                ++i;
            }
            
            InputStream in = System.in;

/*
            if (server) {
                System.err.println("Error: Server not implemented yet");
                System.exit(1);
            }
*/

            if (maxMsecs > 0) {
                Timer timer = new Timer();
                timer.schedule(new ExitTask(), maxMsecs);
            }

            ANTLRInputStream stream = new ANTLRInputStream(in);
            KodkodiLexer lexer = new KodkodiLexer(stream);
            KodkodiParser parser = KodkodiParser.create(verbose, exitOnSuccess,
                                                        cleanUpInst, maxThreads,
                                                        lexer);
            int numErrors = 0;

            try {
                parser.problems();
            } catch (RecognitionException except) {
                if (parser != null)
                    parser.reportError(except);
                System.exit(1);
            }
            if (parser.getTokenStream().LA(1) != KodkodiParser.EOF) {
                System.err.println("Error: trailing tokens");
                System.exit(1);
            }

            numErrors += parser.getNumberOfSyntaxErrors();
            numErrors += lexer.getNumberOfSyntaxErrors();
            System.exit(numErrors > 0 ? 1 : 0);
        } catch (Exception except) {
            String message = except.getMessage();
            if (message.length() == 0)
                message = except.toString();
            System.err.println("Error: " + message);
//            except.printStackTrace();
            System.exit(1);
        }
    }
}
