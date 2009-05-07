/*
    Title:      Kodkodi.g
    Author:     Jasmin Blanchette, TU Muenchen
    License:    See COPYRIGHT for details.
*/

grammar Kodkodi;

@lexer::members {
public void emitErrorMessage(String message) {
    System.err.println(message);
    System.exit(1);
}
}

@parser::header {
package de.tum.in.isabelle.Kodkodi;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Vector;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import kodkod.ast.BinaryExpression;
import kodkod.ast.BinaryIntExpression;
import kodkod.ast.ComparisonFormula;
import kodkod.ast.Decl;
import kodkod.ast.Decls;
import kodkod.ast.ExprToIntCast;
import kodkod.ast.Expression;
import kodkod.ast.Formula;
import kodkod.ast.IntComparisonFormula;
import kodkod.ast.IntConstant;
import kodkod.ast.IntExpression;
import kodkod.ast.IntToExprCast;
import kodkod.ast.Node;
import kodkod.ast.QuantifiedFormula;
import kodkod.ast.Relation;
import kodkod.ast.UnaryExpression;
import kodkod.ast.UnaryIntExpression;
import kodkod.ast.Variable;
import kodkod.ast.operator.ExprCastOperator;
import kodkod.ast.operator.ExprOperator;
import kodkod.ast.operator.IntCastOperator;
import kodkod.ast.operator.IntCompOperator;
import kodkod.ast.operator.IntOperator;
import kodkod.ast.operator.Multiplicity;
import kodkod.engine.Solution;
import kodkod.engine.Solver;
import kodkod.engine.config.Options;
import kodkod.engine.fol2sat.HigherOrderDeclException;
import kodkod.engine.fol2sat.UnboundLeafException;
import kodkod.engine.satlab.SATFactory;
import kodkod.instance.Bounds;
import kodkod.instance.Instance;
import kodkod.instance.Tuple;
import kodkod.instance.TupleFactory;
import kodkod.instance.TupleSet;
import kodkod.instance.Universe;
import kodkod.util.ints.IntSet;
import kodkod.util.ints.SparseSequence;
import org.antlr.runtime.CommonTokenStream;
}

@parser::members {
boolean verbose;
boolean exitOnSuccess;
boolean cleanUpInst;
Lexer lexer;
int problemNo = 0;
long startParsingTime;
Options options;
Universe universe;
TupleFactory factory;
Bounds bounds;
ExecutorService executor = null;
int nextInt;
HashMap<Integer, Relation> atomRelations;
HashMap<Integer, Relation> univRelations;
Relation[] smallSets = new Relation[10];
Vector<Vector<Relation>> relations = new Vector<Vector<Relation>>();
Vector<Vector<Variable>> variables = new Vector<Vector<Variable>>();
Vector<Vector<TupleSet>> tupleSets;
Vector<Vector<Tuple>> tuples;
Vector<Expression> exprs;
Vector<IntExpression> intExprs;
Vector<Formula> formulas;
HashMap<Integer, IntConstant> intConstants =
    new HashMap<Integer, IntConstant>();

public final void reset() {
    ++problemNo;
    startParsingTime = System.currentTimeMillis();
    options = new Options();
    universe = null;
    factory = null;
    bounds = null;
    nextInt = 0;
    atomRelations = new HashMap<Integer, Relation>(); 
    univRelations = new HashMap<Integer, Relation>();
    tupleSets = new Vector<Vector<TupleSet>>();
    tuples = new Vector<Vector<Tuple>>();
    exprs = new Vector<Expression>();
    intExprs = new Vector<IntExpression>();
    formulas = new Vector<Formula>();
}

public final static KodkodiParser create(boolean verbose, boolean exitOnSuccess,
                                         boolean cleanUpInst, int maxThreads,
                                         Lexer lexer) {
    KodkodiParser parser = new KodkodiParser(new CommonTokenStream(lexer));
    parser.verbose = verbose;
    parser.exitOnSuccess = exitOnSuccess;
    parser.cleanUpInst = cleanUpInst;
    parser.lexer = lexer;
    if (maxThreads > 1)
        parser.executor = Executors.newFixedThreadPool(maxThreads);
    return parser;
}

public final void emitErrorMessage(String message) {
    System.err.println(message);
    System.exit(1);
}

private final static String fixedMessage(Throwable except) {
    StringBuilder buf = new StringBuilder(except.getMessage());
    if (buf.length() > 0 && buf.charAt(buf.length() - 1) == '.')
        buf.deleteCharAt(buf.length() - 1);
    return buf.toString();
}

private final void setTuple(Token token, Tuple tuple) {
    final String text = token.getText();
    final int arity = arity(text);
    final int id = id(text);

    if (arity >= tuples.size()) {
        int oldSize = tuples.size();
        tuples.setSize(arity + 1);
        for (int i = oldSize; i <= arity; ++i)
            tuples.setElementAt(new Vector<Tuple>(), i);
    }
    if (id >= tuples.elementAt(arity).size())
        tuples.elementAt(arity).setSize(id + 1);
    tuples.elementAt(arity).setElementAt(tuple, id);
}
private final void setTupleSet(Token token, TupleSet tupleSet) {
    final String text = token.getText();
    final int arity = arity(text);
    final int id = id(text);

    if (arity >= tupleSets.size()) {
        int oldSize = tupleSets.size();
        tupleSets.setSize(arity + 1);
        for (int i = oldSize; i <= arity; ++i)
            tupleSets.setElementAt(new Vector<TupleSet>(), i);
    }
    if (id >= tupleSets.elementAt(arity).size())
        tupleSets.elementAt(arity).setSize(id + 1);
    tupleSets.elementAt(arity).setElementAt(tupleSet, id);
}
private final void setFormulaReg(Token token, Formula formula) {
    final int id = id(token.getText());
    if (id >= formulas.size())
        formulas.setSize(id + 1);
    formulas.setElementAt(formula, id);
}
private final void setExprReg(Token token, Expression expr) {
    final int id = id(token.getText());
    if (id >= exprs.size())
        exprs.setSize(id + 1);
    exprs.setElementAt(expr, id);
}
private final void setIntExprReg(Token token, IntExpression intExpr) {
    final int id = id(token.getText());
    if (id >= intExprs.size())
        intExprs.setSize(id + 1);
    intExprs.setElementAt(intExpr, id);
}
private final void setReg(Token token, Node node) {
    switch (token.getText().charAt(1)) {
    case 'f':
        setFormulaReg(token, (Formula)node);
        break;
    case 'e':
        setExprReg(token, (Expression)node);
        break;
    case 'i':
        setIntExprReg(token, (IntExpression)node);
        break;
    default:
        panic();
    }
}

private final TupleSet univTupleSet(Token token, int id)
{
    int card = card(id);
    int offset = offset(id);

    if (card == 0) {
        return factory.noneOf(1);
    } else if (card + offset > universe.size()) {
        huh(token, "universe too small for '" + token.getText() + "'");
        return factory.noneOf(1);
    } else {
        return factory.range(factory.tuple(universe.atom(offset)),
                             factory.tuple(universe.atom(card + offset - 1)));
    }
}
private final Object getAtom(Token token) {
    final String text = token.getText();
    try {
        return universe.atom(id(text));
    } catch (IndexOutOfBoundsException except) {
        huh(token, "atom '" + text + "' not in universe");
        return universe.atom(0);
    }
}
private final Relation getRelation(Token token) {
    final String text = token.getText();
    int arity = 1;
    int id;
    Relation relation = null;

    if (text.charAt(0) == 'A') {
        id = id(text);
        relation = atomRelations.get(id);
        if (relation == null) {
            relation = Relation.nary(text, 1);
            try {
                bounds.boundExactly(relation, factory.setOf(universe.atom(id)));
            } catch (IndexOutOfBoundsException except) {
                huh(token, "atom '" + text + "' not in universe");
            }
            atomRelations.put(id, relation);
        }
        return relation;
    } else if (text.charAt(0) == 'u') {
        id = id(text);
        relation = univRelations.get(id);
        if (relation == null) {
            relation = Relation.nary(text, 1);
            bounds.boundExactly(relation, univTupleSet(token, id));
            univRelations.put(id, relation);
        }
        return relation;
    } else if (text.charAt(0) == 's' && text.length() == 2) {
        id = text.charAt(1) - '0';
        relation = smallSets[id];
        if (relation != null)
            return relation;
    } else {
        arity = arity(text);
        id = id(text);
    }

    if (arity < relations.size() && id < relations.elementAt(arity).size()) {
        relation = relations.elementAt(arity).elementAt(id);
    } else {
        if (arity >= relations.size()) {
            int oldSize = relations.size();
            relations.setSize(arity + 1);
            for (int i = oldSize; i <= arity; ++i)
                relations.setElementAt(new Vector<Relation>(), i);
        }
        relations.elementAt(arity).setSize(id + 1);
    }
    if (relation == null) {
        relation = Relation.nary(text, arity);
        relations.elementAt(arity).setElementAt(relation, id);
        if (arity == 1 && id < 10)
            smallSets[id] = relation;
    }
    return relation;
}
private final Variable getVariable(Token token) {
    final String text = token.getText();
    final int arity = arity(text);
    final int id = id(text);
    Variable variable = null;

    if (arity < variables.size() && id < variables.elementAt(arity).size()) {
        variable = variables.elementAt(arity).elementAt(id);
    } else {
        if (arity >= variables.size()) {
            int oldSize = variables.size();
            variables.setSize(arity + 1);
            for (int i = oldSize; i <= arity; ++i)
                variables.setElementAt(new Vector<Variable>(), i);
        }
        variables.elementAt(arity).setSize(id + 1);
    }
    if (variable == null) {
        variable = Variable.nary(text, arity);
        variables.elementAt(arity).setElementAt(variable, id);
    }
    return variable;
}
private final TupleSet getTupleSet(Token token) {
    final String text = token.getText();
    final int arity = arity(text);
    final int id = id(text);

    if (arity < tupleSets.size() && id < tupleSets.elementAt(arity).size()) {
        return tupleSets.elementAt(arity).elementAt(id);
    } else {
        huh(token, "No such tuple set '" + text + "'");
        return factory.noneOf(arity);
    }
}
private final Tuple getTuple(Token token) {
    final String text = token.getText();
    final int arity = arity(text);
    final int id = id(text);

    if (arity < tuples.size() && id < tuples.elementAt(arity).size()) {
        return tuples.elementAt(arity).elementAt(id);
    } else {
        huh(token, "No such tuple '" + text + "'");
        return factory.tuple(1, 0);
    }
}
private final Formula getFormulaReg(Token token) {
    final String text = token.getText();
    try {
        Formula formula = formulas.elementAt(id(text));
        if (formula != null) {
            return formula;
        } else {
            huh(token, "No such formula '" + text + "'");
            return Formula.FALSE;
        }
    } catch (IndexOutOfBoundsException except) {
        huh(token, "No such formula '" + text + "'");
        return Formula.FALSE;
    }
}
private final Expression getExprReg(Token token) {
    final String text = token.getText();
    try {
        Expression expr = exprs.elementAt(id(text));
        if (expr != null) {
            return expr;
        } else {
            huh(token, "No such relational expression '" + text + "'");
            return Expression.NONE;
        }
    } catch (IndexOutOfBoundsException except) {
        huh(token, "No such relational expression '" + text + "'");
        return Expression.NONE;
    }
}
private final IntExpression getIntExprReg(Token token) {
    final String text = token.getText();
    try {
        IntExpression intExpr = intExprs.elementAt(id(token.getText()));
        if (intExpr != null) {
            return intExpr;
        } else {
            huh(token, "No such integer expression '" + text + "'");
            return IntConstant.constant(0);
        }
    } catch (IndexOutOfBoundsException except) {
        huh(token, "No such integer expression '" + text + "'");
        return IntConstant.constant(0);
    }
}
private final IntConstant getIntConstant(Token token)
{
    final int value = getInt(token);
    IntConstant intConstant = intConstants.get(value);
    if (intConstant == null) {
        intConstant = IntConstant.constant(value);
        intConstants.put(value, intConstant);
    }
    return intConstant;
}
private final int getInt(String text) {
    try {
        return Integer.parseInt(text);
    } catch (NumberFormatException except) {
        huh(Token.INVALID_TOKEN, "integer '" + text + "' out of range");
        return 0;
    }
}
private final int getInt(Token token) {
    return getInt(token, token.getText());
}
private final int getInt(Token token, String text) {
    try {
        return Integer.parseInt(text);
    } catch (NumberFormatException except) {
        huh(token, "integer '" + text + "' out of range");
        return 0;
    }
}

private final void huh(Token token, String message) {
    SemanticException except = new SemanticException(token, message);
    reportError(except);
}
private final void panic() {
    Exception except = new Exception();
    System.err.println("this cannot happen");
    except.printStackTrace();
    System.exit(1);
}

private final int arity(String name) {
    int start = 0;

    if (name.charAt(0) == '$')
        ++start;

    switch (name.charAt(start)) {
    case 'A':
    case 'a':
    case 'S':
    case 's':
    case 'u':
        return 1;
    case 'P':
    case 'p':
    case 'R':
    case 'r':
        return 2;
    case 'M':
    case 'm':
    case 'T':
    case 't':
        {
            final int mid = name.indexOf('_');
            if (mid >= 0) {
                int nary = getInt(name.substring(start + 1, mid));
                if (nary >= 3) {
                    return nary;
                } else {
                    huh(Token.INVALID_TOKEN,
                        "expected arity 3 or more, got " + nary);
                    return 3;
                }
            }
        }
    }

    panic();
    return 0;
}
private final int OFFSET_LIMIT = 65536;
private final int CARD_LIMIT = 65536;
private final int universeId(int card, int offset) {
    if (card < 0 || card >= CARD_LIMIT) {
        huh(Token.INVALID_TOKEN,
            "expected reasonable cardinality, got '" + card + "'");
        return 0;
    }
    if (offset < 0 || offset >= OFFSET_LIMIT) {
        huh(Token.INVALID_TOKEN,
            "expected reasonable offset, got '" + offset + "'");
        return 0;
    }
    return offset * CARD_LIMIT + card;
}
private final int card(int id) { return id \% CARD_LIMIT; }
private final int offset(int id) { return id / CARD_LIMIT; }
private final int id(String name) {
    int start = 0;

    if (name.charAt(0) == '$')
        ++start;

    switch (name.charAt(start)) {
    case 'A':
    case 'a':
    case 'e':
    case 'f':
    case 'i':
    case 'P':
    case 'p':
    case 'R':
    case 'r':
    case 's':
        {
            int id = getInt(name.substring(start + 1));
            if (id >= 0) {
                return id;
            } else {
                huh(Token.INVALID_TOKEN,
                    "expected nonnegative ID, got '" + id + "'");
                return 0;
            }
        }
    case 'S':
        {
            int id;
            if (name.endsWith("'")) {
                int rawId = getInt(name.substring(start + 1, name.length() - 1));
                id = 2 * rawId + 1;
            } else {
                int rawId = getInt(name.substring(start + 1));
                id = 2 * rawId;
            }
            if (id >= 0) {
                return id;
            } else {
                huh(Token.INVALID_TOKEN,
                    "expected nonnegative ID, got '" + id + "'");
                return 0;
            }
        }
    case 'M':
    case 'm':
    case 'T':
    case 't':
        {
            final int mid = name.indexOf('_');
            if (mid >= 0) {
                int id = getInt(name.substring(mid + 1));
                if (id >= 0) {
                    return id;
                } else {
                    huh(Token.INVALID_TOKEN,
                        "expected nonnegative ID, got '" + id + "'");
                    return 0;
                }
            }
        }
        break;
    case 'u':
        {
            final int mid = name.indexOf('@');
            int card;
            int offset = 0;
            if (mid >= 0) {
                card = getInt(name.substring(start + 1, mid));
                offset = getInt(name.substring(mid + 1));
            } else {
                card = getInt(name.substring(start + 1));
            }
            return universeId(card, offset);
        }
    }

    panic();
    return 0;
}
private final String sstr(Token token) {
    String str = token.getText();
    if (str.length() >= 2) {
        return str.substring(1, str.length() - 1);
    } else {
        panic();
        return "";
    }
}

private final Formula F(Token token, Object object) {
    try {
        return (Formula)object;
    } catch (ClassCastException except) {
        huh(token, "expected formula");
        return Formula.FALSE;
    }
}
private final Expression E(Token token, Object object) {
    try {
        return (Expression)object;
    } catch (ClassCastException except) {
        huh(token, "expected relational expression");
        return Expression.NONE;
    }
}
private final IntExpression I(Token token, Object object) {
    try {
        return (IntExpression)object;
    } catch (ClassCastException except) {
        huh(token, "expected integer expression");
        return IntConstant.constant(0);
    }
}
private final static boolean isExpression(Object object) {
    try {
        Expression expr = (Expression)object;
        return true;
    } catch (ClassCastException except) {
        return false;
    }
}
private final static boolean isIntExpression(Object object) {
    try {
        IntExpression expr = (IntExpression)object;
        return true;
    } catch (ClassCastException except) {
        return false;
    }
}

private final static class SemanticException extends RecognitionException {
    String message;

    public SemanticException(Token token, String message) {
        this.token = token;
        line = token.getLine();
        charPositionInLine = token.getCharPositionInLine();
        this.message = message;
    }

    public final String getMessage() { return message; }
}

private final static boolean isRealRelation(Relation relation) {
    switch (relation.name().charAt(0)) {
    case 's':
    case 'r':
    case 'm':
        return true;
    default:
        return false;
    }
}

private final static Instance cleanedUpInstance(Instance instance, Bounds bounds,
                                                boolean aggressive)
{
    Instance result = new Instance(bounds.universe());
    Set<Relation> relations = instance.relations();

    Map<Relation, TupleSet> lowerBounds = bounds.lowerBounds();
    Map<Relation, TupleSet> upperBounds = bounds.upperBounds();
    Map<Relation, TupleSet> relationTuples = instance.relationTuples();

    for (Relation relation : relations) {
        if ((aggressive
             && !lowerBounds.get(relation).equals(upperBounds.get(relation)))
            || isRealRelation(relation))
            result.add(relation, relationTuples.get(relation));
    }

    SparseSequence<TupleSet> intBounds = bounds.intBounds();
    SparseSequence<TupleSet> intTuples = instance.intTuples();
    int[] indices = intTuples.indices().toArray();

    for (int index : indices) {
        TupleSet tuples = intTuples.get(index);
        if (!intBounds.get(index).equals(tuples))
            result.add(index, tuples);
    }
    return result;
}

private final void solve(Token token, int problemNo, long parsingTime,
                         Options options, Universe universe, Bounds bounds,
                         Formula formula)
{
    final Solver solver = new Solver(options);
    try {
        final Solution solution = solver.solve(formula, bounds);

        final StringBuilder buf = new StringBuilder();
        buf.append("\n*** PROBLEM " + problemNo + " ***\n");
        buf.append("\n---OUTCOME---\n");
        buf.append(solution.outcome());
        if (verbose) {
            buf.append("\n---UNIVERSE---\n" + universe.toString() + "\n");
            buf.append("\n---BOUNDS---\n" + bounds.toString() + "\n");
            buf.append("\n---FORMULA---\n" + formula.toString() + "\n");
        }
        buf.append("\n");
        if (solution.instance() != null) {
            buf.append("\n---INSTANCE---\n");
            buf.append(cleanedUpInstance(solution.instance(), bounds,
                                         cleanUpInst));
            buf.append("\n");
        }
        if (solution.proof() != null) {
            buf.append("\n---PROOF---\n");
            buf.append(solution.proof());
            buf.append("\n");
        }
        buf.append("\n---STATS---\n");
        buf.append(solution.stats());

        int pos = buf.lastIndexOf("translation time:");
        if (pos == -1)
            pos = buf.length();
        buf.insert(pos, "parsing time: " + parsingTime + " ms\n");

        pos = buf.lastIndexOf("ints: []\n");
        if (pos != -1)
            buf.delete(pos, pos + 9);

        System.out.println(buf);

        if (exitOnSuccess
                && (solution.outcome() == Solution.Outcome.TRIVIALLY_SATISFIABLE
                    || solution.outcome() == Solution.Outcome.SATISFIABLE))
            System.exit(0);
    } catch (UnboundLeafException except) {
        huh(token, "formula contains unbounded leaf expression: "
                    + except.leaf());
    } catch (HigherOrderDeclException except) {
        huh(token, "formula contains unskolemizable higher-order declaration: "
                   + except.decl());
    } catch (NoClassDefFoundError except) {
        huh(token, "could not execute SAT solver: missing class "
                   + except.getMessage());
    } catch (UnsatisfiedLinkError except) {
        huh(token, "could not execute SAT solver: " + fixedMessage(except));
    } catch (IndexOutOfBoundsException except) {
        huh(token, "arity too large for cardinality of universe");
    } catch (ArithmeticException except) {
        huh(token, "arithmetic exception");
    } catch (OutOfMemoryError except) {
        huh(token, "out of memory");
    }
}

public class SingletonArrayList<T> extends ArrayList<T> {
    public SingletonArrayList(T elem) {
        add(elem);
    }
}
}

@lexer::header {
package de.tum.in.isabelle.Kodkodi;
}

problems:
        problem* {
            if (executor != null) {
                try {
                    executor.shutdown();
                    executor.awaitTermination(31622400L, TimeUnit.SECONDS);
                } catch (InterruptedException except) {
                    panic();
                }
            }
        };
problem:
        { reset(); }
        option*
        univ_spec
        tuple_reg_directive*
        bound_spec*
        int_bound_spec?
        expr_reg_directive*
        solve_directive;
option returns [Vector<String> strs = new Vector<String>()]:
        SOLVER COLON s1 = STR_LITERAL { strs.add(sstr($s1)); }
        (COMMA s2 = STR_LITERAL { strs.add(sstr($s2)); })* {
            int expected = 1;
            SATFactory solver = null;
            if (strs.elementAt(0).equals("DefaultSAT4J")) {
                solver = SATFactory.DefaultSAT4J;
            } else if (strs.elementAt(0).equals("LightSAT4J")) {
                solver = SATFactory.LightSAT4J;
            } else if (strs.elementAt(0).equals("ZChaff")
                       || strs.elementAt(0).equals("zChaff")) {
                solver = SATFactory.ZChaff;
            } else if (strs.elementAt(0).equals("ZChaffMincost")
                       || strs.elementAt(0).equals("zChaffMincost")) {
                solver = SATFactory.ZChaffMincost;
            } else if (strs.elementAt(0).equals("MiniSatProver")) {
                solver = SATFactory.MiniSatProver;
            } else if (strs.elementAt(0).equals("MiniSat")) {
                solver = SATFactory.MiniSat;
            } else if (strs.elementAt(0).equals("SAT4J")) {
                expected = 2;
                if (strs.size() >= 2)
                    solver = SATFactory.sat4jFactory(strs.elementAt(1));
            } else if (strs.elementAt(0).equals("External")) {
                expected = 4;
                if (strs.size() >= expected) {
                    String[] args = new String[strs.size() - expected];
                    for (int i = expected; i < strs.size(); ++i)
                        args[i - expected] = strs.elementAt(i);
                    solver = SATFactory.externalFactory(strs.elementAt(1),
                                                        strs.elementAt(2),
                                                        strs.elementAt(3),
                                                        args);
                }
            } else if (strs.elementAt(0).equals("ExternalV2")) {
                expected = 7;
                if (strs.size() >= expected) {
                    String[] args = new String[strs.size() - expected];
                    for (int i = expected; i < strs.size(); ++i)
                        args[i - expected] = strs.elementAt(i);
                    solver = ExternalSolverV2.satFactory(strs.elementAt(1),
                                                         strs.elementAt(2),
                                                         strs.elementAt(3),
                                                         strs.elementAt(4),
                                                         strs.elementAt(5),
                                                         strs.elementAt(6),
                                                         args);
                }
            }

            if (solver != null) {
                options.setSolver(solver);
            } else {
                huh($s1, "unknown SAT solver '" + strs + "'");
            }

            if (strs.size() < expected
                    || (expected <= 2 && strs.size() > expected)) {
                huh($s1, "expected " + expected + " strings, got "
                         + strs.size());
            }
        } |
        SYMMETRY_BREAKING COLON k = NUM {
            try {
                options.setSymmetryBreaking(getInt($k));
            } catch (IllegalArgumentException except) {
                huh($k, "symmetry breaking value " + $k.text
                        + " out of range");
            }
        } |
        SHARING COLON k = NUM {
            try {
                options.setSharing(getInt($k));
            } catch (IllegalArgumentException except) {
                huh($k, "sharing value " + $k.text + " out of range");
            }
        } |
        BIT_WIDTH COLON k = NUM {
            try {
                options.setBitwidth(getInt($k));
            } catch (IllegalArgumentException except) {
                huh($k, "bit width value " + $k.text + " out of range");
            }
        } |
        SKOLEM_DEPTH COLON k = NUM {
            try {
                options.setSkolemDepth(getInt($k));
            } catch (IllegalArgumentException except) {
                huh($k, "Skolem depth value " + $k.text + " out of range");
            }
        } |
        FLATTEN COLON t = (TRUE | FALSE) {
            options.setFlatten($t.type == TRUE);
        };
univ_spec:
        UNIV COLON n = UNIV_NAME {
            int cardinality = id($n.text);
            if (cardinality == 0) {
                huh($n, "invalid universe '" + $n.text + "'");
                cardinality = 1;
            }
            final List<String> atoms = new ArrayList<String>(cardinality);
            for (int i = 0; i < cardinality; ++i)
                atoms.add(new String("A" + i));
            universe = new Universe(atoms);
            factory = universe.factory();
            bounds = new Bounds(universe);
        };
tuple_reg_directive:
        r = TUPLE_SET_REG c = COLON_EQ s = tuple_set[arity($r.text)] {
            if ($s.value.arity() == arity($r.text)) {
                setTupleSet($r, $s.value);
            } else {
                huh($c, "expected " + arity($r.text) + "-tuple set, got "
                         + $s.value.arity() + "-tuple set");
            }
        } |
        r = TUPLE_REG c = COLON_EQ t = tuple[arity($r.text)] {
            if ($t.value.arity() == arity($r.text)) {
                setTuple($r, $t.value);
            } else {
                huh($c, "expected " + arity($r.text) + "-tuple, got "
                        + $t.value.arity() + "-tuple");
            }
        };
bound_spec returns [List<Relation> relations = new ArrayList<Relation>()]:
        BOUNDS n1 = RELATION_NAME { $relations.add(getRelation($n1)); }
        (COMMA n2 = RELATION_NAME { $relations.add(getRelation($n2)); })*
        c = COLON
        (s1 = tuple_set[$relations.get(0).arity()] |
         BRACKET_LEFT s1 = tuple_set[$relations.get(0).arity()]
         COMMA s2 = tuple_set[$relations.get(0).arity()] BRACKET_RIGHT) {
            try {
                if (s2 == null) {
                    for (Relation relation : relations) {
                        if (bounds.lowerBound(relation) == null) {
                            bounds.boundExactly(relation, $s1.value);
                        } else {
                            huh($c, "relation already bound");
                        }
                    }
                } else {
                    for (Relation relation : relations) {
                        if (bounds.lowerBound(relation) == null) {
                            bounds.bound(relation, $s1.value, $s2.value);
                        } else {
                            huh($c, "relation already bound");
                        }
                    }
                }
            } catch (IllegalArgumentException except) {
                huh($c, "invalid bounds: " + fixedMessage(except));
            }
        };
int_bound_spec:
        INT_BOUNDS COLON q = int_bound_seq (COMMA q = int_bound_seq)*;
expr_reg_directive:
        r = FORMULA_REG COLON_EQ e = expr { setFormulaReg($r, F($r, $e.node)); } |
        r = REL_EXPR_REG COLON_EQ e = expr { setExprReg($r, E($r, $e.node)); } |
        r = INT_EXPR_REG COLON_EQ e = expr { setIntExprReg($r, I($r, $e.node)); };
solve_directive:
        s = SOLVE e = expr SEMICOLON {
            final long parsingTime = System.currentTimeMillis() - startParsingTime;
            final Token token = $s;
            final int problemNo = this.problemNo;
            final Options options = this.options;
            final Universe universe = this.universe;
            final Bounds bounds = this.bounds;
            final Formula formula = F($s, $e.node);

            Runnable task = new Runnable() {
                public void run() {
                    try {
                        solve(token, problemNo, parsingTime, options, universe,
                              bounds, formula);
                    } catch (Exception except) {
                        String message = except.getMessage();
                        if (message.length() == 0)
                            message = except.toString();
                        System.err.println("Error: " + message);
                        System.exit(1);
                    }
                }
            };
            if (executor != null) {
                executor.execute(task);
            } else {
                task.run();
            }
        };

int_bound_seq:
        (k = NUM COLON)? q = tuple_set_seq[1] {
            if (k != null)
                nextInt = getInt($k);
            for (TupleSet tupleSet : $q.value) {
                try {
                    bounds.boundExactly(nextInt, tupleSet);
                } catch (IllegalArgumentException except) {
                    huh($q.token, "invalid bounds: " + fixedMessage(except));
                }
                ++nextInt;
            }
        };
tuple_set_seq[int arity]
     returns [Token token, List<TupleSet> value = new ArrayList<TupleSet>()]:
        b = BRACKET_LEFT (s1 = tuple_set[$arity] {
            $token = $b;
            $value.add($s1.value);
        } (COMMA s2 = tuple_set[$arity]{ $value.add($s2.value); })*)?
        BRACKET_RIGHT;

tuple_set[int arity] returns [TupleSet value]:
        s1 = intersect_tuple_set[$arity] { $value = $s1.value; }
        (t = (PLUS | MINUS) s2 = intersect_tuple_set[$arity] {
             try {
                 if ($t.type == PLUS) {
                     $value.addAll($s2.value);
                 } else {
                     $value.removeAll($s2.value);
                 }
             } catch (IllegalArgumentException except) {
                  huh($t, "illegal tuple set: " + fixedMessage(except));
             }
         })*;
intersect_tuple_set[int arity] returns [TupleSet value]:
        s1 = product_tuple_set[$arity] { $value = $s1.value; }
        (a = AND s2 = product_tuple_set[$arity] {
             try {
                 $value.retainAll($s2.value);
             } catch (IllegalArgumentException except) {
                  huh($a, "illegal tuple set: " + fixedMessage(except));
             }
         })*;
product_tuple_set[int arity] returns [TupleSet value]:
        s1 = project_tuple_set[$arity] { $value = $s1.value; }
        (a = ARROW s2 = project_tuple_set[$arity] {
             try {
                 $value = $value.product($s2.value);
             } catch (IllegalArgumentException except) {
                  huh($a, "illegal tuple set: " + fixedMessage(except));
             }
         })*;
project_tuple_set[int arity] returns [TupleSet value]:
        s = basic_tuple_set[$arity] { $value = $s.value; }
        (BRACKET_LEFT k = NUM BRACKET_RIGHT {
             final int dimension = getInt($k);
             try {
                 $value = $value.project(dimension);
             } catch (IllegalArgumentException except) {
                 huh($k, "dimension " + dimension + " out of range");
                 $value = $s.value;
             }
         })*;
basic_tuple_set[int arity]
       returns [TupleSet value, List<Tuple> list = new ArrayList<Tuple>()]:
        n = (UNIV_NAME | OFFSET_UNIV_NAME) {
              $value = univTupleSet($n, id($n.text));
        } |
        PAREN_LEFT s = tuple_set[$arity] { $value = $s.value; } PAREN_RIGHT |
        b = BRACE_LEFT
        (t1 = tuple[$arity]
         ({
              $list.add($t1.value);
          } (COMMA t2 = tuple[$arity] {
                 $list.add($t2.value);
             })* {
              try {
                  $value = factory.setOf($list);
              } catch (IllegalArgumentException except) {
                  huh($b, "illegal tuple set: " + fixedMessage(except));
              }
          } |
          dd = DOT_DOT t2 = tuple[$arity] {
              try {
                  $value = factory.range($t1.value, $t2.value);
              } catch (IndexOutOfBoundsException except) {
                  huh($dd, "invalid range");
                  $value = factory.setOf($t1.value);   
              } catch (IllegalArgumentException except) {
                  huh($dd, "invalid range");
                  $value = factory.setOf($t1.value);
              }
          } |
          h = HASH t2 = tuple[$arity] {
              try {
                  $value = factory.area($t1.value, $t2.value);
              } catch (IndexOutOfBoundsException except) {
                  huh($h, "invalid area");
                  $value = factory.setOf($t1.value);
              } catch (IllegalArgumentException except) {
                  huh($h, "invalid area");
                  $value = factory.setOf($t1.value);
              }
          }) |
         {
              try {
                  $value = factory.noneOf(arity);
              } catch (IllegalArgumentException except) {
                  huh($b, "arity " + arity + " too large for universe of " +
                          "cardinality " + universe.size());
              }
         })
        BRACE_RIGHT |
        n = NONE {
              try {
                  $value = factory.noneOf(arity);
              } catch (IllegalArgumentException except) {
                  huh($n, "arity " + arity + " too large for universe of " +
                          "cardinality " + universe.size());
              }
        } |
        a = ALL {
              try {
                  $value = factory.allOf(arity);
              } catch (IllegalArgumentException except) {
                  huh($a, "arity " + arity + " too large for universe of " +
                          "cardinality " + universe.size());
              }
        } |
        r = TUPLE_SET_REG { $value = getTupleSet($r); };
tuple[int arity] returns [Tuple value, List<Object> atoms]:
        BRACKET_LEFT n1 = ATOM_NAME {
            $atoms = new ArrayList<Object>();
            $atoms.add(getAtom($n1));
        } (COMMA n2 = ATOM_NAME {
               $atoms.add(getAtom($n2));
           })* BRACKET_RIGHT { $value = factory.tuple($atoms); } |
        n = ATOM_NAME {
            $value = factory.tuple(getAtom($n));
        } |
        n = TUPLE_NAME {
            final String text = $n.text;
            try {
                $value = factory.tuple(arity(text), id(text));
            } catch (IllegalArgumentException except) {
                huh($n, "tuple index out of range");
                $value = factory.tuple(arity(text), 0);
            }
        } |
        r = TUPLE_REG { $value = getTuple($r); };

expr returns [Object node]:
        ALL ds = decls b = BAR e = expr {
            if ($ds.nodes == null) {
                $node = F($b, $e.node);
            } else {
                $node = F($b, $e.node).forAll($ds.nodes);
            }
        } |
        SOME ds = decls b = BAR e = expr {
            if ($ds.nodes == null) {
                $node = F($b, $e.node);
            } else {
                $node = F($b, $e.node).forSome($ds.nodes);
            }
        } |
        SUM ds = decls b = BAR e = expr {
            try {
                $node = I($b, $e.node).sum($ds.nodes);
            } catch (IllegalArgumentException except) {
                huh($b, "expected one or more declarations with multiplicity "
                        + "'one'");
            }
        } |
        l = LET as = assigns BAR e = expr {
            $node = $e.node;
            for (int j = $as.oldNodes.size() - 1; j >= 0; --j)
                setReg($as.tokens.elementAt(j), $as.oldNodes.elementAt(j));
        } |
        i = IF e = expr t = THEN e1 = expr u = ELSE e2 = expr {
            if (isExpression($e1.node)) {
                try {
                    $node = F($i, $e.node)
                            .thenElse(E($t, $e1.node), E($u, $e2.node));
                } catch (IllegalArgumentException except) {
                    int arity1 = E($t, $e1.node).arity();
                    int arity2 = E($u, $e2.node).arity();
                    if (arity1 == arity2) {
                        panic();
                    } else {
                        huh($u, "arity mismatch (" + arity1 + " vs. " + arity2
                                + ")");
                    }
                }
            } else if (isIntExpression($e1.node)) {
                $node = F($i, $e.node)
                        .thenElse(I($t, $e1.node), I($u, $e2.node));
            } else {
                Formula f = F($i, $e.node);
                $node = (f.and(F($u, $e1.node)))
                        .or(f.not().and(F($u, $e2.node)));
            }
        } |
        e1 = iff_formula { $node = $e1.node; }
        (o = OR es = or_formula_tail[$o,
                             new SingletonArrayList<Formula>(F($o, $node))]
             { $node = $es.node; })?;
or_formula_tail[Token token, List<Formula> formulas] returns [Object node]:
        e1 = iff_formula { $formulas.add(F(token, $e1.node)); }
        (OR es = or_formula_tail[$token, $formulas] { $node = $es.node; } |
         { $node = Formula.or($formulas); });
iff_formula returns [Object node]:
        e1 = implies_formula { $node = $e1.node; }
        (i = IFF e2 = implies_formula {
             $node = F($i, $node).iff(F($i, $e2.node));
         })*;
implies_formula returns [Object node]:
        e1 = and_formula { $node = $e1.node; }
        (i = IMPLIES e2 = implies_formula {
             $node = F($i, $node).implies(F($i, $e2.node));
         })?;
and_formula returns [Object node]:
        e1 = basic_formula { $node = $e1.node; }
        (a = AND es = and_formula_tail[$a,
                          new SingletonArrayList<Formula>(F($a, $node))]
             { $node = $es.node; })?;
and_formula_tail[Token token, List<Formula> formulas] returns [Object node]:
        e1 = basic_formula { $formulas.add(F(token, $e1.node)); }
        (AND es = and_formula_tail[$token, $formulas] { $node = $es.node; } |
         { $node = Formula.and($formulas); });
basic_formula returns [Object node]:
        t = NOT e1 = basic_formula { $node = F($t, $e1.node).not(); } |
        e1 = predicate_formula { $node = $e1.node; } |
        e1 = shift_expr
        (t = (EQ | LT | LE | GT | GE | IN) e2 = shift_expr {
             if (isExpression($e1.node)) {
                 try {
                     if ($t.type == EQ) {
                         $node = E($t, $e1.node).eq(E($t, $e2.node));
                     } else if ($t.type == IN) {
                         $node = E($t, $e1.node).in(E($t, $e2.node));                 
                     } else {
                         huh($t, "mismatched input '" + $t.text
                                 + "' expecting EQ or IN");
                         $node = Formula.FALSE;
                     }
                 } catch (IllegalArgumentException except) {
                     int arity1 = E($t, $e1.node).arity();
                     int arity2 = E($t, $e2.node).arity();
                     if (arity1 == arity2) {
                         panic();
                     } else {
                         huh($t, "arity mismatch (" + arity1 + " vs. " + arity2
                                 + ")");
                     }
                 }
             } else if (isIntExpression($e1.node)) {
                 if ($t.type != IN) {
                     $node = I($t, $e1.node).compare(
                                 $t.type == EQ
                                     ? IntCompOperator.EQ
                               : $t.type == LT
                                     ? IntCompOperator.LT
                               : $t.type == LE
                                     ? IntCompOperator.LTE
                               : $t.type == GT
                                     ? IntCompOperator.GT
                               : IntCompOperator.GTE,
                                 I($t, $e2.node));
                 } else {
                     huh($t, "mismatched input 'in' expecting EQ, LT, GT,"
                             + " etc.");
                     $node = Formula.FALSE;
                 }
             } else {
                 huh($t, "operands may not be formulas");
             }
         } | {
             $node = $e1.node;
         }) |
        m = multiplicity e1 = add_expr {
            if ($m.value != Multiplicity.SET) {
                $node = E($m.token, $e1.node).apply($m.value);
            } else {
                huh($m.token, "invalid multiplicity 'set'");
            }
        };
predicate_formula returns [Object node]:
        a = ACYCLIC PAREN_LEFT n = RELATION_NAME PAREN_RIGHT {
            try {
                $node = getRelation($n).acyclic();
            } catch (IllegalArgumentException except) {
                huh($a, "invalid arity");
            }
        } |
        f = FUNCTION PAREN_LEFT n = RELATION_NAME c = COMMA e1 = expr ARROW
        t = (ONE | LONE) e2 = expr PAREN_RIGHT {
            try {
                Relation relation = getRelation($n);
                $node = ($t.type == ONE
                             ? relation.function(E($c, $e1.node),
                                                 E($t, $e2.node))
                             : relation.partialFunction(E($c, $e1.node),
                                                        E($t, $e2.node)));
            } catch (IllegalArgumentException except) {
                huh($f, "invalid arity");
            }
        } |
        t = TOTAL_ORDERING PAREN_LEFT n1 = RELATION_NAME COMMA
        n2 = (UNIV_NAME | OFFSET_UNIV_NAME | RELATION_NAME) COMMA
        n3 = (ATOM_NAME | RELATION_NAME) COMMA n4 = (ATOM_NAME | RELATION_NAME)
        PAREN_RIGHT {
            try {
                $node = getRelation($n1).totalOrder(getRelation($n2),
                                                    getRelation($n3),
                                                    getRelation($n4));
            } catch (IllegalArgumentException except) {
                huh($t, "invalid arity");
            }
        };
shift_expr returns [Object node]:
        e1 = add_expr { $node = $e1.node; }
        (t = (SHL | SHA | SHR) e2 = add_expr {
             $node = I($t, $node).compose(
                                 $t.type == SHL
                                     ? IntOperator.SHL
                               : $t.type == SHA
                                     ? IntOperator.SHA
                                     : IntOperator.SHR,
                                 I($t, $e2.node));
         })*;
add_expr returns [Object node]:
        e1 = mult_expr { $node = $e1.node; }
        (t = (PLUS | MINUS) e2 = mult_expr {
             if (isExpression($node)) {
                 try {
                     $node = E($t, $node).compose(
                                     $t.type == PLUS
                                         ? ExprOperator.UNION
                                         : ExprOperator.DIFFERENCE,
                                     E($t, $e2.node));
                 } catch (IllegalArgumentException except) {
                     int arity1 = E($t, $node).arity();
                     int arity2 = E($t, $e2.node).arity();
                     if (arity1 == arity2) {
                         panic();
                     } else {
                         huh($t, "arity mismatch (" + arity1 + " vs. " + arity2
                                 + ")");
                     }
                 }
             } else if (isIntExpression($node)) {
                 $node = I($t, $node).compose(
                                 $t.type == PLUS
                                     ? IntOperator.PLUS
                                     : IntOperator.MINUS,
                                 I($t, $e2.node));
             } else {
                 huh($t, "operands may not be formulas");
             }
         })*;
mult_expr returns [Object node]:
        e1 = expr_to_int_cast { $node = $e1.node; }
        (t = (STAR | DIVIDE | MODULO) e2 = expr_to_int_cast {
             $node = I($t, $node).compose(
                             $t.type == STAR
                                 ? IntOperator.MULTIPLY
                           : $t.type == DIVIDE
                                 ? IntOperator.DIVIDE
                                 : IntOperator.MODULO,
                             I($t, $e2.node));
         })*;
expr_to_int_cast returns [Object node]:
        t = (HASH | SUM) PAREN_LEFT e = expr PAREN_RIGHT {
            try {
                $node = E($t, $e.node).apply($t.type == HASH
                                           ? ExprCastOperator.CARDINALITY
                                           : ExprCastOperator.SUM);
             } catch (IllegalArgumentException except) {
                 huh($t, "illegal arity");
             }
        } |
        e1 = product_expr { $node = $e1.node; }
        (o = (BAR | HAT | AMP) e2 = product_expr {
             if ($o.type == BAR) {
                 $node = I($o, $node).or(I($o, $e2.node));
             } else if ($o.type == HAT) {
                 $node = I($o, $node).xor(I($o, $e2.node));
             } else {
                 if (isExpression($node)) {
                     try {
                         $node = E($o, $node).intersection(E($o, $e2.node));
                     } catch (IllegalArgumentException except) {
                         int arity1 = E($o, $node).arity();
                         int arity2 = E($o, $e2.node).arity();
                         if (arity1 == arity2) {
                             panic();
                         } else {
                             huh($o, "arity mismatch (" + arity1 + " vs. "
                                     + arity2 + ")");
                         }
                     }
                 } else if (isIntExpression($node)) {
                     $node = I($o, $node).and(I($o, $e2.node));
                 } else {
                     huh($o, "operands may not be formulas");
                 }
             }
        })* (o = OVERRIDE e2 = expr_to_int_cast {
                 try {
                     $node = E($o, $node).override(E($o, $e2.node));
                 } catch (IllegalArgumentException except) {
                     int arity1 = E($o, $node).arity();
                     int arity2 = E($o, $e2.node).arity();
                     if (arity1 == arity2) {
                         panic();
                     } else {
                         huh($o, "arity mismatch (" + arity1 + " vs. "
                                 + arity2 + ")");
                     }
                 }
             })?;
product_expr returns [Object node]:
        e1 = ifno_expr { $node = $e1.node; }
        (a = ARROW es = product_expr_tail[$a,
                            new SingletonArrayList<Expression>(E($a, $node))]
             { $node = $es.node; })?;
product_expr_tail[Token token, List<Expression> exprs] returns [Object node]:
        e1 = ifno_expr { $exprs.add(E(token, $e1.node)); }
        (ARROW es = product_expr_tail[$token, $exprs] { $node = $es.node; } |
         { $node = Expression.product($exprs); });
ifno_expr returns [Object node]:
        e1 = apply_expr { $node = $e1.node; }
        (a = IFNO e2 = apply_expr {
             $node = E($a, $node).no().thenElse(E($a, $e2.node), E($a, $node));
         })*;
apply_expr returns [Object node]:
        e1 = project_expr { $node = $e1.node; }
        (p = PAREN_LEFT e2 = expr {
             try {
                 $node = E($p, $e2.node).join(E($p, $node));
             } catch (IllegalArgumentException except) {
                 int arity1 = E($p, $node).arity();
                 int arity2 = E($p, $e2.node).arity();
                 if (arity1 + arity2 > 2) {
                     panic();
                 } else {
                     huh($p, "illegal arities (1 and 1)");
                 }
             }
         } (COMMA e3 = expr {
             try {
                 $node = E($p, $e3.node).join(E($p, $node));
             } catch (IllegalArgumentException except) {
                 int arity1 = E($p, $node).arity();
                 int arity2 = E($p, $e3.node).arity();
                 if (arity1 + arity2 > 2) {
                     panic();
                 } else {
                     huh($p, "illegal arities (1 and 1)");
                 }
             }
         })* PAREN_RIGHT)*;
project_expr returns [Object node]:
        e1 = basic_expr { $node = $e1.node; }
        (d = DOT e2 = basic_expr {
             try {
                 $node = E($d, $node).join(E($d, $e2.node));
             } catch (IllegalArgumentException except) {
                 int arity1 = E($d, $node).arity();
                 int arity2 = E($d, $e2.node).arity();
                 if (arity1 + arity2 > 2) {
                     panic();
                 } else {
                     huh($d, "illegal arities (1 and 1)");
                 }
             }
         })* (cs = project_columns {
                  IntExpression[] array = new IntExpression[$cs.nodes.size()];
                  $cs.nodes.toArray(array);
                  $node = E($cs.token, $node).project(array);
              })*;
basic_expr returns [Object node]:
        PAREN_LEFT e = expr PAREN_RIGHT { $node = $e.node; } |
        n = (ATOM_NAME | UNIV_NAME | OFFSET_UNIV_NAME | RELATION_NAME)
            { $node = getRelation($n); } |
        n = VARIABLE_NAME { $node = getVariable($n); } |
        r = FORMULA_REG { $node = getFormulaReg($r); } |
        r = REL_EXPR_REG { $node = getExprReg($r); } |
        r = INT_EXPR_REG { $node = getIntExprReg($r); } |
        n = NUM { $node = getIntConstant($n); } |
        FALSE { $node = Formula.FALSE; } |
        TRUE { $node = Formula.TRUE; } |
        IDEN { $node = Expression.IDEN; } |
        INTS { $node = Expression.INTS; } |
        NONE { $node = Expression.NONE; } |
        UNIV { $node = Expression.UNIV; } |
        t = (HAT | STAR | TILDE | ABS | SGN | MINUS) e = basic_expr {
            if (isExpression($e.node)) {
                try {
                    if ($t.type == HAT) {
                        $node = E($t, $e.node).closure();
                    } else if ($t.type == STAR) {
                        $node = E($t, $e.node).reflexiveClosure();
                    } else if ($t.type == TILDE) {
                        $node = E($t, $e.node).transpose();
                    } else {
                        huh($t, "mismatched input '" + $t.text
                                + "' expecting HAT, STAR, or TILDE");
                        $node = Formula.FALSE;
                    }
                } catch (IllegalArgumentException except) {
                    if (E($t, $e.node).arity() == 2) {
                        panic();
                    } else {
                        huh($t, "illegal arity");
                    }
                }
            } else if (isIntExpression($e.node)) {
                if ($t.type == ABS) {
                    $node = I($t, $e.node).abs();
                } else if ($t.type == SGN) {
                    $node = I($t, $e.node).signum();
                } else if ($t.type == MINUS) {
                    $node = I($t, $e.node).negate();
                } else if ($t.type == TILDE) {
                    $node = I($t, $e.node).not(); 
                } else {
                    huh($t, "mismatched input '" + $t.text
                            + "' expecting ABS, SGN, MINUS, or TILDE");
                    $node = IntConstant.constant(0);
                }
            } else {
                huh($t, "operands may not be formulas");
            }
        } |
        BRACE_LEFT ds = decls t = BAR e = expr BRACE_RIGHT {
            try {
                $node = F($t, $e.node).comprehension($ds.nodes);
            } catch (IllegalArgumentException except) {
                huh($t, "expected declarations with multiplicity 'one'");
            } catch (NullPointerException except) {
                huh($t, "expected at least one declaration");
            }
        } |
        t = (BITS | INT) BRACKET_LEFT e = expr BRACKET_RIGHT {
            $node = I($t, $e.node).cast($t.type == BITS
                                      ? IntCastOperator.BITSETCAST
                                      : IntCastOperator.INTCAST);
        };

decls returns [Decls nodes = null]:
        BRACKET_LEFT
        (d1 = decl { $nodes = $d1.node; }
         (COMMA d2 = decl { $nodes = $nodes.and($d2.node); })*)?
        BRACKET_RIGHT;
decl returns [Decl node]:
        n = VARIABLE_NAME c = COLON m = multiplicity e = expr {
            try {
                $node = getVariable($n).declare($m.value, E($c, $e.node));
            } catch (IllegalArgumentException except) {
                huh($c, "invalid bound: " + fixedMessage(except));
            }
        };
assigns returns [Vector<Token> tokens = new Vector<Token>(),
                 Vector<Node> oldNodes = new Vector<Node>(),
                 Vector<Node> newNodes = new Vector<Node>()]:
        BRACKET_LEFT assign[$tokens, $oldNodes, $newNodes]
        (COMMA assign[$tokens, $oldNodes, $newNodes])* BRACKET_RIGHT {
            for (int i = 0; i < $tokens.size(); ++i)
                setReg($tokens.elementAt(i), $newNodes.elementAt(i));
        };
assign[Vector<Token> tokens, Vector<Node> oldNodes, Vector<Node> newNodes]:
        r = FORMULA_REG c = COLON_EQ e = expr {
            int id = id($r.text);
            $tokens.add($r);
            $oldNodes.add(id < formulas.size() ? formulas.elementAt(id) : null);
            $newNodes.add(F($c, $e.node));
        } |
        r = REL_EXPR_REG c = COLON_EQ e = expr {
            int id = id($r.text);
            $tokens.add($r);
            $oldNodes.add(id < exprs.size() ? exprs.elementAt(id) : null);
            $newNodes.add(E($c, $e.node));
        } |
        r = INT_EXPR_REG c = COLON_EQ e = expr {
            int id = id($r.text);
            $tokens.add($r);
            $oldNodes.add(id < intExprs.size() ? intExprs.elementAt(id) : null);
            $newNodes.add(I($c, $e.node));
        };
multiplicity returns [Token token, Multiplicity value]:
        t = (NO | LONE | ONE | SOME | SET) {
            $token = $t;
            switch ($t.type) {
            case NO:
                $value = Multiplicity.NO;
                break;
            case LONE:
                $value = Multiplicity.LONE;
                break;
            case ONE:
                $value = Multiplicity.ONE;
                break;
            case SOME:
                $value = Multiplicity.SOME;
                break;
            case SET:
                $value = Multiplicity.SET;
            }
        };
project_columns
       returns [Token token,
                Vector<IntExpression> nodes = new Vector<IntExpression>()]:
        t = BRACKET_LEFT e1 = expr {
            $token = $t;
            $nodes.add(I($t, $e1.node));
        } (c = COMMA e2 = expr { $nodes.add(I($c, $e2.node)); })*
        BRACKET_RIGHT;

ATOM_NAME:      'A' NAT;
UNIV_NAME:      'u' NAT;
OFFSET_UNIV_NAME:
                'u' NAT '@' NAT;
TUPLE_NAME:     ('P' | 'T' NAT '_') NAT;
RELATION_NAME:  ('s' | 'r' | 'm' NAT '_') NAT;
VARIABLE_NAME:  ('S' | 'R' | 'M' NAT '_') NAT '\''?;
TUPLE_SET_REG:  '$' ('a' | 'p' | 't' NAT '_') NAT;
TUPLE_REG:      '$' ('A' | 'P' | 'T' NAT '_') NAT;
FORMULA_REG:    '$f' NAT;
REL_EXPR_REG:   '$e' NAT;
INT_EXPR_REG:   '$i' NAT;

NUM:            (PLUS | MINUS)? '0'..'9'+;
fragment NAT:   '0' | '1'..'9' '0'..'9'*;
STR_LITERAL:    '"' ~('"' | '\n')* '"';
WHITESPACE:     (' ' | '\n' | '\r' | '\t' | '\v')+ { skip(); };
INLINE_COMMENT: '//' ~('\n')* { skip(); };
BLOCK_COMMENT:  '/*' (options { greedy = false; } : .)* '*/' { skip(); };

AMP:            '&';
AND:            '&&';
ARROW:          '->';
COLON_EQ:       ':=';
BAR:            '|';
BRACE_LEFT:     '{';
BRACE_RIGHT:    '}';
BRACKET_LEFT:   '[';
BRACKET_RIGHT:  ']';
COLON:          ':';
COMMA:          ',';
DIVIDE:         '/';
DOT:            '.';
DOT_DOT:        '..';
EQ:             '=';
GE:             '>=';
GT:             '>';
HASH:           '#';
HAT:            '^';
IFF:            '<=>';
IFNO:           '\\';
IMPLIES:        '=>';
LT:             '<';
LE:             '<=';
MINUS :         '-';
MODULO:         '%';
NOT:            '!';
OVERRIDE :      '++';
OR:             '||';
PAREN_LEFT:     '(';
PAREN_RIGHT:    ')';
PLUS:           '+';
SEMICOLON:      ';';
SHA:            '>>';
SHL:            '<<';
SHR:            '>>>';
STAR:           '*';
TILDE:          '~';

ABS:            'abs';
ACYCLIC:        'ACYCLIC';
ALL:            'all';
BITS:           'Bits';
BIT_WIDTH:      'bit_width';
BOUNDS:         'bounds';
ELSE:           'else';
FALSE:          'false';
FLATTEN:        'flatten';
FUNCTION:       'FUNCTION';
IDEN:           'iden';
IF:             'if';
IN:             'in';
INT:            'Int';
INT_BOUNDS:     'int_bounds';
INTS:           'ints';
LET:            'let';
LONE:           'lone';
NO:             'no';
NONE:           'none';
ONE:            'one';
RELATION:       'relation';
SET:            'set';
SGN:            'sgn';
SHARING:        'sharing';
SKOLEM_DEPTH:   'skolem_depth';
SOLVE:          'solve';
SOLVER:         'solver';
SOME:           'some';
SUM:            'sum';
SYMMETRY_BREAKING:
                'symmetry_breaking';
THEN:           'then';
TOTAL_ORDERING: 'TOTAL_ORDERING';
TRUE:           'true';
UNIV:           'univ';
