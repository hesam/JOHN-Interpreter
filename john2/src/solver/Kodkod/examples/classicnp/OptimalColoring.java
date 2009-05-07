package examples.classicnp;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

/**
 * KK encoding of the graph coloring problem that uses a minimizing SAT solver.
 * 
 * @author Emina Torlak
 */
public final class OptimalColoring {
	private final Relation Node, Color, color, graph;
	
	/**
	 * Creates an instance of the graph coloring problem.
	 */
	public OptimalColoring() {
		super();
		Node = Relation.unary("Node");
		Color = Relation.unary("Color");
		color = Relation.binary("color");
		graph = Relation.binary("graph");
	}

	/**
	 * Returns a formula stating that all vertices
	 * have at least one color, and that no two adjacent
	 * vertices have intersecting colors.
	 * @return a formula stating that all vertices
	 * have at least one color, and that no two adjacent
	 * vertices have intersecting colors.
	 */
	public Formula coloring() {
		final Variable n = Variable.unary("n");
		final Formula f0 = n.join(color).intersection(Color).some();
		final Formula f1 = n.join(color).intersection(n.join(graph).join(color)).no();
		return (f0.and(f1)).forAll(n.oneOf(Node));
	}
	
	/**
	 * Returns the cost function that needs to be minimized during solving (# colors used).
	 * @return the cost function that needs to be minimized during solving (# colors used).
	 */
	public Cost cost() {
		return new Cost() {

			public int edgeCost(Relation relation) {
				return relation==Color ? 1 : 0;
			}
			
		};
	}
	
	/**
	 * Returns the bounds for the myciel3 graph (http://mat.gsia.cmu.edu/COLOR/instances/myciel3.col).
	 * @return bounds for the myciel3 graph.
	 */
	public Bounds myciel3() {
		final List<String> atoms = new ArrayList<String>(16);
		for(int i = 1; i <= 11; i++)
			atoms.add("n"+i);
		for(int i = 1; i <= 5; i++)
			atoms.add("c"+i);
		final Universe u = new Universe(atoms);
		final Bounds b = new Bounds(u);
		final TupleFactory f = u.factory();
		
		b.boundExactly(Node, f.range(f.tuple("n1"), f.tuple("n11")));
		b.bound(Color, f.range(f.tuple("c1"), f.tuple("c5")));
		b.bound(color, b.upperBound(Node).product(b.upperBound(Color)));
		
		final TupleSet g = f.noneOf(2);
		g.add(f.tuple("n1", "n2"));
		g.add(f.tuple("n1", "n4"));
		g.add(f.tuple("n1", "n7"));
		g.add(f.tuple("n1", "n9"));
		g.add(f.tuple("n2", "n3"));
		g.add(f.tuple("n2", "n6"));
		g.add(f.tuple("n2", "n8"));
		g.add(f.tuple("n3", "n5"));
		g.add(f.tuple("n3", "n7"));
		g.add(f.tuple("n3", "n10"));
		g.add(f.tuple("n4", "n5"));
		g.add(f.tuple("n4", "n6"));
		g.add(f.tuple("n4", "n10"));
		g.add(f.tuple("n5", "n8"));
		g.add(f.tuple("n5", "n9"));
		g.add(f.tuple("n6", "n11"));
		g.add(f.tuple("n7", "n11"));
		g.add(f.tuple("n8", "n11"));
		g.add(f.tuple("n9", "n11"));
		g.add(f.tuple("n10", "n11"));
		b.boundExactly(graph, g);
		
		return b;
	}
	
	private static void add(Map<String, Set<String>> m, String k, String v) {
		Set<String> vl = m.get(v);
		if (vl==null || !vl.contains(k)) {
			Set<String> kl = m.get(k);
			if (kl == null) {
				kl = new HashSet<String>();
				m.put(k, kl);
			}
			kl.add(v);
		}
	}
	
	/**
	 * Extracts the bounds for the graph described in the given file in the DIMACS format.
	 * @return the bounds for the graph described in the given file in the DIMACS format.
	 */
	@SuppressWarnings("unchecked")
	public Bounds fromFile(String filename) {
		final File file = new File(filename);
		Bounds b = null;
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line = reader.readLine();
			
			while(line != null && line.charAt(0)=='c') { // skip comments
				line = reader.readLine();
			}
			
			// read the problem line
			assert line !=  null && line.charAt(0)=='p';
			String[] split = line.split("\\s+");
			
			final int nodes = Integer.parseInt(split[2]), edges = Integer.parseInt(split[3]);
			Map<String, Set<String>> data = new HashMap<String, Set<String>>();
			Map<String, Set<String>> symm = new HashMap<String, Set<String>>();
			
			// read the problem
			for(line = reader.readLine(); line != null; line = reader.readLine()) {
				split = line.split("\\s+");
				if (split[0].equals("e")) {
					add(data, split[1], split[2]);
					add(symm, split[2], split[1]);
				}
			}
			
			reader.close();
			
			// determine the maximum vertex degree
			int colors = 0;
			for(Map.Entry<String, Set<String>> e : data.entrySet()) {
				Set<String> symmVal = symm.get(e.getKey());
				if (symmVal==null) {
					colors = StrictMath.max(colors, e.getValue().size());
				} else {
					symmVal.removeAll(e.getValue());
					colors = StrictMath.max(colors, e.getValue().size() + symmVal.size());
				}
			}
			symm = null;
			colors = colors / 2;
			System.out.println(filename + ":: " +"nodes: " + nodes + ", edges " + edges + ", max colors: " + colors);
			
			final List<String> atoms = new ArrayList<String>(nodes + colors);
			for(int i = 1; i <= nodes; i++) {
				atoms.add(String.valueOf(i));
			}
			for(int i = 1; i <= colors; i++) {
				atoms.add("c"+i);
			}
			
			final Universe u = new Universe(atoms);
			b = new Bounds(u);
			final TupleFactory f = u.factory();
			
			b.boundExactly(Node, f.range(f.tuple("1"), f.tuple(String.valueOf(nodes))));
			b.bound(Color, f.range(f.tuple("c1"), f.tuple("c"+String.valueOf(colors))));
			b.bound(color, b.upperBound(Node).product(b.upperBound(Color)));
			
			final TupleSet g = f.noneOf(2);
			for(Map.Entry<String, Set<String>> e : data.entrySet()) {
				String k = e.getKey();
				for(String v : e.getValue()) {
					g.add(f.tuple(k, v));
				}
			}
			b.boundExactly(graph, g);
		} catch (FileNotFoundException e) {
			System.out.println(filename + " not found.");
		} catch (IOException e) {
			System.out.println("Cannot read " + filename);		
		} catch (RuntimeException re) {
			System.out.println(filename + " is not in DIMACS format");
		} 
		
		return b;
	}
	
	/**
	 * Usage: java examples.classicnp.OptimalColoring [filename]
	 */
	public static void main(String[] args) {
		final OptimalColoring model = new OptimalColoring();
		final Solver solver = new Solver();
		
	
			final Formula f = model.coloring();
			final Bounds b = args.length>0 ? model.fromFile(args[0]) : model.myciel3();
			if (b==null) return;
			//System.out.println(f);
			System.out.println("solving...");
			solver.options().setSolver(SATFactory.ZChaffMincost);
			final Solution solm = solver.solve(f, b, model.cost());
			System.out.println(solm);
			
//			solver.options().setSolver(SATFactory.MiniSat);
//			final Solution solb = solver.solve(f, b);
//			System.out.println(solb);
//			if (solb.instance()!=null) {
//				System.out.println((new Evaluator(solb.instance())).evaluate(f));
//			}

		
	}
}
