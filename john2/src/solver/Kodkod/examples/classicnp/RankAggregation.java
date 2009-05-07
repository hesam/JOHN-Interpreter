package examples.classicnp;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import static kodkod.ast.Expression.union;
import kodkod.ast.Expression;
import kodkod.ast.Formula;
import kodkod.ast.Relation;
import kodkod.ast.Variable;
import kodkod.engine.Cost;
import kodkod.engine.Solution;
import kodkod.engine.Solver;
import kodkod.engine.satlab.SATFactory;
import kodkod.instance.Bounds;
import kodkod.instance.TupleFactory;
import kodkod.instance.TupleSet;
import kodkod.instance.Universe;
import kodkod.util.nodes.PrettyPrinter;

/**
 * A toy implementation of the Kemeny rank aggregation function.
 * 
 * @author Emina Torlak
 */
public final class RankAggregation {
	private final Relation[] rankings;
	private final Relation kemeny, disagrees, kfirst, klast, elts;
	
	/**
	 * Constructs a RankAggregation model for finding the Kemeny rank
	 * for the given number of rankings.
	 */
	public RankAggregation(int numRankings) {
		assert numRankings > 0;
		this.rankings = new Relation[numRankings];
		for(int i = 0; i < numRankings; i++)
			rankings[i] = Relation.binary("r"+i);
		this.kemeny = Relation.binary("kemeny");
		this.kfirst = Relation.unary("kfirst");
		this.klast = Relation.unary("klast");
		this.disagrees = Relation.binary("disagrees");
		this.elts = Relation.unary("elts");
	}

	/**
	 * Returns a formula stating that the kemeny relation imposes a total
	 * on the universe.
	 * @return a formula stating that the kemeny relation imposes a total
	 * on the universe.
	 */
	public Formula declarations() {
		return kemeny.totalOrder(elts, kfirst, klast);
	}
	
	/**
	 * Returns a formula defining the kemeny relation in terms of a cost function.
	 * @return a formula defining the kemeny relation in terms of a cost function.
	 */
	public Formula kemeny() {
		final Variable e = Variable.unary("e");
		Expression[] closures = new Expression[rankings.length]; 
		for(int i = 0; i < rankings.length; i++) {
			closures[i] = rankings[i].closure();
		}
		return e.join(disagrees).eq(e.join(kemeny.closure()).intersection(union(closures).join(e))).forAll(e.oneOf(elts));
	}
	
	/**
	 * Returns the cost function that needs to be minimized during solving.
	 * @return the cost function that needs to be minimized during solving.
	 */
	public Cost cost() {
		return new Cost() {

			public int edgeCost(Relation relation) {
				return relation==disagrees ? 1: 0;
			}
			
		};
	}
	
	/**
	 * Returns the conjunction of declarations() and kemeny().
	 * @return declarations() && kemeny()
	 */
	public Formula show() { 
		return declarations().and(kemeny());
	}
	
	/**
	 * Returns a bounds for a random universe of the given size.
	 * @requires usize > 1
	 * @return bounds for a random universe of the given size
	 */
	public Bounds bounds(int usize) {
		assert usize > 1;
		final List<String> atoms = new ArrayList<String>(usize);
		for(int i = 0; i < usize; i++) {
			atoms.add(String.valueOf(i));
		}
		final Universe u = new Universe(atoms);
		final TupleFactory f = u.factory();
		final Bounds b = new Bounds(u);
		
		b.boundExactly(elts, f.allOf(1));
		b.bound(kfirst, b.upperBound(elts));
		b.bound(klast, b.upperBound(elts));
		final TupleSet kbound = f.noneOf(2);
		for(int i = 0; i < usize; i ++) {
			for(int j = 0; j < usize; j++) {
				if (i!=j) {
					kbound.add(f.tuple(atoms.get(i), atoms.get(j)));
				}
			}
		}
		b.bound(kemeny, kbound);
		b.bound(disagrees, f.allOf(2));
		
		final long seed = 1209158694505L;//System.currentTimeMillis();
		final Random rand = new Random(seed);
		for(Relation r : rankings) {
			Collections.shuffle(atoms, rand);
			TupleSet rbound = f.noneOf(2);
			for(int i = 1; i < usize; i++) {
				rbound.add(f.tuple(atoms.get(i-1), atoms.get(i)));
			}
			b.boundExactly(r, rbound);
		}
		
		return b;
	}
	
	private static void usage() {
		System.out.println("Usage: java examples.RankAggregation [# entries] [# rankings]");
		System.exit(1);
	}
	
	/**
	 * Usage: java examples.RankAggregation [# entries] [# rankings]
	 */
	public static void main(String[] args) {
		if (args.length < 2) 
			usage();
		
		try {
			final RankAggregation model = new RankAggregation(Integer.parseInt(args[1]));
			final Solver solver = new Solver();
			
			Formula f = model.show();
			Bounds b = model.bounds(Integer.parseInt(args[0]));
			System.out.println(PrettyPrinter.print(f, 2));
			System.out.println(b);
			
			System.out.println("solving with mincost");
			solver.options().setSolver(SATFactory.ZChaffMincost);
			Solution solm = solver.solve(f, b, model.cost());
			System.out.println(solm);
			
		} catch (NumberFormatException nfe) {
			usage();
		}
	}
}	
