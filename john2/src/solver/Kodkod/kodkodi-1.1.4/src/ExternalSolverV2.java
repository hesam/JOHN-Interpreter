/*
    Title:      ExternalSolverV2.java
    Authors:    Emina Torlek, MIT
                Jasmin Blanchette, TU Muenchen
    License:    See COPYRIGHT for details.
*/    
/*
 * This file was adapted from ExternalSolver.java distributed with Kodkod
 * (2008-11-25 version) by Jasmin Christian Blanchette. The original
 * copyright notice is reproduced below. The changes to the original file
 * are Copyright 2009 Technische Universitaet Muenchen, like the rest of the
 * Kodkodi software.
 */    
/*    
 * Kodkod -- Copyright (c) 2005-2007, Emina Torlak
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package de.tum.in.isabelle.Kodkodi;    
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.RandomAccessFile;
import java.util.BitSet;
import kodkod.engine.satlab.SATAbortedException;
import kodkod.engine.satlab.SATFactory;
import kodkod.engine.satlab.SATSolver;    
/**
 * An implementation of a wrapper for an external SAT solver,    
 * executed in a separate process.
 * @author Emina Torlak
 */
final class ExternalSolverV2 implements SATSolver {
    private final StringBuilder buffer;
    private final int capacity = 8192;
    private final String executable, inTemp, outTemp;
    private final String[] options;
    private final RandomAccessFile cnf;
    private final BitSet solution;
    private volatile Boolean sat;
    private volatile int vars, clauses;
    private String satTag, solutionTag, unsatTag;    
    /**
     * Constructs an ExternalSolverV2 that will execute the specified binary
     * with the given options on the inTemp file with the specified name.  inTemp
     * will be initialized to contain all clauses added to this solver via the    
     * {@link #addClause(int[])} method.  If outTemp is the empty string,    
     * the solver is assumed to write its output to standard out.  Otherwise,
     * it is assumed to write its output to the outTemp file.
     *
     * satTag, solutionTag, and unsatTag specify the file format.
     */
    ExternalSolverV2(String executable, String inTemp, String outTemp,
                     String satTag, String solutionTag, String unsatTag,
                     String... options) {
        try {
            this.cnf = new RandomAccessFile(inTemp,"rw");
            this.cnf.setLength(0);
            // get enough space into the buffer for the cnf header, which will be written last
            this.buffer = new StringBuilder();
            for(int i = headerLength(); i > 0; i--) {
                buffer.append(" ");
            }
            buffer.append("\n");
            this.sat = null;
            this.solution = new BitSet();
            this.vars = 0;
            this.clauses = 0;
            this.executable = executable;
            this.options = options;
            this.inTemp = inTemp;
            this.outTemp = outTemp;
            this.satTag = satTag;
            this.solutionTag = solutionTag;
            this.unsatTag = unsatTag;
        } catch (FileNotFoundException e) {
            throw new RuntimeException("SAT solver aborted: " + e);
         } catch (IOException e) {
            throw new RuntimeException("SAT solver aborted: " + e);
        }    
    }    
    /**
     * Returns the length, in characters, of the longest possible header
     * for a cnf file: p cnf Integer.MAX_VALUE Integer.MAX_VALUE
     * @return the length, in characters, of the longest possible header
     * for a cnf file: p cnf Integer.MAX_VALUE Integer.MAX_VALUE
     */
    private static final int headerLength() {
        return String.valueOf(Integer.MAX_VALUE).length()*2 + 8;
    }    
    /**
     * Flushes the contents of the string buffer to the cnf file.
     */
    private final void flush(){    
        try {
            cnf.writeBytes(buffer.toString());
        } catch (IOException e) {
            throw new RuntimeException("SAT solver aborted: " + e);
        }
        buffer.setLength(0);
    }    
    /**
     * {@inheritDoc}
     * @see kodkod.engine.satlab.SATSolver#addClause(int[])
     */
    public boolean addClause(int[] lits) {
        if (lits.length>0) {
            clauses++;
            if (buffer.length()>capacity) flush();
            for(int lit: lits) {
                buffer.append(lit);
                buffer.append(" ");
            }
            buffer.append("0\n");
            return true;
        }
        return false;
    }    
    /**
     * @see kodkod.engine.satlab.SATSolver#addVariables(int)
     */
    public void addVariables(int numVars) {
        if (numVars < 0)
            throw new IllegalArgumentException("vars < 0: " + numVars);
        vars += numVars;
    }    
    /**
     * @see kodkod.engine.satlab.SATSolver#free()
     */
    public synchronized void free() {
        try {
            cnf.close();
            new File(inTemp).delete();
            if (outTemp.length() != 0)
                new File(outTemp).delete();
        } catch (IOException e) {
            // do nothing
        }
    }    
    /**
     * Releases the resources used by this external solver.
     */
    protected final void finalize() throws Throwable {
        super.finalize();
        free();
    }    
    /**
     * @see kodkod.engine.satlab.SATSolver#numberOfClauses()
     */
    public int numberOfClauses() {
        return clauses;
    }    
    /**
     * @see kodkod.engine.satlab.SATSolver#numberOfVariables()
     */
    public int numberOfVariables() {
        return vars;
    }    
    /**
     * @effects |lit| <= this.vars && lit != 0 => this.solution'.set(|lit|, lit>0)
     * @throws RuntimeException - lit=0 || |lit|>this.vars
     */
    private final void updateSolution(int lit) {
        int abs = StrictMath.abs(lit);
        if (abs<=vars && abs>0)
            solution.set(abs-1, lit>0);
        else
            throw new RuntimeException("invalid variable value: |" + lit + "| !in [1.."+vars+"]");
    }    
    /** Helper class that drains the stderr. */
    private final class Drainer implements Runnable {
        /** The stream to drain. */
        private final InputStream input;
        /** Constructor that constructs a new Drainer. */
        public Drainer(InputStream input) {
            this.input=input;
        }
        /** The run method that keeps reading from the InputStream until end-of-file. */
        public void run() {
            try {
                byte[] buffer=new byte[8192];
                while(true) {
                    int n=input.read(buffer);
                    if (n<0) break;
                }
            } catch (IOException ex) {
            }
            try { input.close(); } catch(IOException ex) { }
        }
    }    
    /**
     * @see kodkod.engine.satlab.SATSolver#solve()
     */
    public boolean solve() throws SATAbortedException {
        if (sat==null) {
            flush();
            Process p = null;
            try {
                cnf.seek(0);
                cnf.writeBytes("p cnf " + vars + " " + clauses);
                cnf.close();    
                final String[] command = new String[options.length + 2];
                command[0] = executable;
                command[1] = inTemp;
                System.arraycopy(options, 0, command, 2, options.length);
                p = Runtime.getRuntime().exec(command);
                new Thread(new Drainer(p.getErrorStream())).start();
                final BufferedReader out;
                if (outTemp.length()==0) {
                    out = new BufferedReader(new InputStreamReader(p.getInputStream(), "ISO-8859-1"));
                } else {
                    try {
                        p.waitFor();
                    } catch (InterruptedException e) {
                        throw new RuntimeException("could not wait for " +
                                                   executable, e);
                    }
                    out = new BufferedReader(new FileReader(outTemp));
                }
                String line = null;
                while((line = out.readLine()) != null) {
                    int j = 0;
                    if (line.indexOf(unsatTag) != -1) {
                        sat = Boolean.FALSE;
                        break;
                    } else if (line.indexOf(satTag) != -1) {
                        sat = Boolean.TRUE;
                        continue;
                    } else if (solutionTag.length() == 0) {
                        if (sat == Boolean.TRUE) {
                            final String[] tokens = line.split("\\s");
                            int last = tokens.length - 1;
                            try {
                                for (int i = 0; i <= last; i++) {
                                    int n = Integer.parseInt(tokens[i]);
                                    if (n != 0)
                                        updateSolution(n);
                                }
                            } catch (NumberFormatException e) {
                                // done (e.g., ran into the word "Random" in
                                // zChaff's output)
                                break;
                            }
                            break;
                        }
                    } else if ((j = line.indexOf(solutionTag)) != -1) {
                        line = line.substring(j + solutionTag.length());
                        final String[] tokens = line.split("\\s");
                        int last = tokens.length - 1;
                        for (int i = 0; i < last; i++) {
                            updateSolution(Integer.parseInt(tokens[i]));
                        }
                        int lit = Integer.parseInt(tokens[last]);
                        if (lit != 0) updateSolution(lit);
                        else if (sat!=null) break;
                    }
                    // not a solution line or a variable line, so ignore it.
                }
                try {
                    out.close();
                } catch (IOException e) { } // do nothing, we are done    
                if (sat==null) {
                    throw new RuntimeException("invalid " + executable +
                                               " output (unknown result)");
                }
            } catch (IOException e) {
                throw new RuntimeException("SAT solver aborted", e);
            } catch (NumberFormatException e) {
                throw new RuntimeException("invalid "+ executable +
                                           " output", e);
            }
        }
        return sat;
    }    
    /**
     * @see kodkod.engine.satlab.SATSolver#valueOf(int)
     */
    public boolean valueOf(int variable) {
        if (!Boolean.TRUE.equals(sat))
            throw new IllegalStateException();
        if (variable < 1 || variable > vars)
            throw new IllegalArgumentException(variable + " !in [1.." + vars+"]");
        return solution.get(variable-1);
    }    
    /**
     * @see java.lang.Object#toString()
     */
    public String toString() {
        return executable + " " + options;
    }    
    public static final SATFactory satFactory(final String executable,
            final String tempInput, final String tempOutput,
            final String satTag, final String solTag, final String unsatTag,
            final String... options) {
        return new SATFactory() {
                    @Override
                    public SATSolver instance() {
                        return new ExternalSolverV2(executable, tempInput,
                                                    tempOutput, satTag, solTag,
                                                    unsatTag, options);
                    }    
                    @Override
                    public boolean incremental() { return false; }
                };
    }
}    