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
package nativesolver;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Generates and runs a system dependent Makefile that creates the dynamically linked
 * libraries needed by {@link kodkod.engine.satlab.SATFactory}.
 * 
 * <p>Usage (dir = directory containing native solver sources): java nativesolver.Make -d dir </p>
 * @author Emina Torlak
 * @author Nicolas F. Rouquette
 */
public final class Make {
	private static final String BASE = "kodkod_engine_satlab_";
	private static final String JNIDIR = headersDir();
	private static final String JLIBDIR = userLibDir();
	private static final String CC = "g++";
	private static final String COMPILE = "$(CC) -Wall -O3 -c";
	private static final String LINK = "$(CC) " + linkFlags();
	
	private static enum FileType {
		NATIVE_HEADERS { public String toString() { return "native headers"; }}, 
		NATIVE_SOURCES { public String toString() { return "native sources"; }},  
		JNI_HEADERS { public String toString() { return "jni headers"; }}, 
		JNI_SOURCES { public String toString() { return "jni sources"; }}
	}
	
	/**
	 * Returns the name of the directory that contains the 
	 * java/jni headers.
	 */
	private static String headersDir() {
		final String JHOME = System.getProperty("java.home");
		return JHOME.substring(0,1+JHOME.lastIndexOf(File.separator))+"Headers";
	}
	
	/**
	 * Returns the name of a directory in which user-supplied
	 * dynamic libraries can be stored.
	 */
	private static String userLibDir() {
		final String[] JLIBDIRS = System.getProperty("java.library.path").split(System.getProperty("path.separator"));
		String ret = null;
		for(String ld: JLIBDIRS) {
			if (ld.equals(".")) continue;
			File ldf = new File(ld);
			if (ldf.canWrite()) {
				ret = ld + File.separator;
				break;
			}
		}
		if (ret==null) {
			System.out.println("All library directories are read-only: " + Arrays.toString(JLIBDIRS));
			System.exit(1);
		}
		return ret;
	}
	
	/**
	 * Returns a platform specific flags for creating
	 * dynamic libraries.
	 */
	private static String linkFlags() {
		if (System.getProperty("os.name").toLowerCase().indexOf("mac") >= 0) {
			return "-dynamiclib";
		} else {
			return "-shared";
		}
	}
	
	private static void generating(File file) {
		System.out.println("# generating " + file);
	}
	
	private static void done(File file) {
		System.out.println("# generated " + file);
	}
	
	private static void failed(File file, String reason) { 
		System.out.println("# couldn't generate " + file + ": " + reason);
	}
	
	/**
	 * Gets the names of the files from the given directory that belong
	 * in one of the four categories designated by the FileType enum.
	 * @return a map from each FileType to the names of the files of that
	 * type, found in the given directory 
	 */
	private static Map<FileType, Set<String>> getNames(File dir) {
		final EnumMap<FileType, Set<String>> ret = new EnumMap<FileType, Set<String>>(FileType.class);
		ret.put(FileType.NATIVE_HEADERS, new HashSet<String>());
		ret.put(FileType.NATIVE_SOURCES, new HashSet<String>());
		ret.put(FileType.JNI_HEADERS, new HashSet<String>());
		ret.put(FileType.JNI_SOURCES, new HashSet<String>());
		
		for(File f : dir.listFiles()) {
			if (f.isFile()) {
				final String name = f.getName();
				final String lcname = name.toLowerCase();
				if (lcname.endsWith(".h")) {
					if (lcname.startsWith(BASE)) 
						ret.get(FileType.JNI_HEADERS).add(name);
					else 
						ret.get(FileType.NATIVE_HEADERS).add(name);
				} else if (lcname.endsWith(".cpp") || lcname.endsWith(".c")) {
					if (lcname.startsWith(BASE))
						ret.get(FileType.JNI_SOURCES).add(name);
					else 
						ret.get(FileType.NATIVE_SOURCES).add(name);
				}
			}
		}
		return ret;
	}
	
	private static String mapLibraryName(Map<FileType, Set<String>> files) {
		final Set<String> jheaders = files.get(FileType.JNI_HEADERS);
		final String header = jheaders.iterator().next();
		return System.mapLibraryName(header.substring(BASE.length(), header.length()-2).toLowerCase());
	}
	/**
	 * Generates the make-file for the given directory.
	 * @return true if generation was successful
	 */
	private static boolean generate(File dir) {
		final File submake = new File(dir, "Makefile");
		try {	 
	
			final Map<FileType, Set<String>> files = getNames(dir);
			for(Map.Entry<FileType,Set<String>> e : files.entrySet()) {
				if (e.getValue().isEmpty()) {
					failed(dir, "found no " + e.getKey());
					return false;
				}
			}
			
			generating(submake);
			final PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(submake)));
			
			// compiler and linker
			out.println("CC = " + CC);
			out.println("COMPILE = " + COMPILE);
			out.println("LINK = " + LINK);
			out.println();
			
			// native headers, sources, and objects
			out.print("CHEADERS = ");
			for(String h: files.get(FileType.NATIVE_HEADERS)) {
				out.print(h);
				out.print(" ");
			}
			out.println();
			out.print("CSRCS = ");
			for(String s: files.get(FileType.NATIVE_SOURCES)) {
				out.print(s);
				out.print(" ");
			}
			out.println();
			out.print("COBJS = ");
			for(String s: files.get(FileType.NATIVE_SOURCES)) {
				out.print(s.split("\\.")[0]);
				out.print(".o");
				out.print(" ");
			}
			out.println();
			out.println();
			// platform stuff
			out.println("U0=$(shell uname)");
			out.println("U1=$(subst SunOS,solaris,${U0})");
			out.println("U2=$(subst CYGWIN.*,cygwin,${U1})");
			out.println("U3=$(subst Darwin,darwin,${U2})");
			out.println("OS=$(subst Linux,linux,${U3})");
			out.println();
			
			// JNI directories, names, headers, sources and objects
			out.println("JNIDIR = " + JNIDIR);
			out.println("JLIBDIR = " + JLIBDIR);
			out.println("JNILIB = " + mapLibraryName(files));
			out.println();
			
			out.print("JHEADERS = ");
			for(String h: files.get(FileType.JNI_HEADERS)) {
				out.print(h);
				out.print(" ");
			}
			out.println();
			out.print("JSRCS = ");
			for(String s: files.get(FileType.JNI_SOURCES)) {
				out.print(s);
				out.print(" ");
			}
			out.println();
			
			out.println("JOBJS = $(JSRCS:.cpp=.o)");
			out.println();
			
			// rules
			out.println("$(COBJS):  $(CHEADERS)");
			out.println("\t$(COMPILE) $(CSRCS)");
			out.println();
			out.println("$(JOBJS):  $(COBJS) $(JHEADERS)");
			out.println("\t$(COMPILE) -I$(JNIDIR) -I. $(JSRCS)");
			out.println();
			out.println("EXTRALIBS=");
			out.println("ifeq \"${OS}\" \"darwin\"");
			out.println("\tEXTRALIBS += -framework JavaVM");
			out.println("endif");
			out.println("");
			out.println("$(JLIBDIR):");
			out.println("\tmkdir -vp $@");
			out.println("");
			out.println("$(JNILIB): $(JLIBDIR) $(COBJS) $(JOBJS)");
			out.println("\t$(LINK) -o $(JLIBDIR)$(JNILIB) $(COBJS) $(JOBJS) $(EXTRALIBS)");
			out.println();
			out.println("clean:");
			out.println("\trm -f *.o");
			out.println();
			out.println("all: $(JNILIB)");
			out.close();
			
			done(submake);
			return true;
			
		} catch (IOException e) {
			failed(submake, e.getMessage());
			return false;
		}
	}
	
	/**
	 * Generates the top-level maindir and the sub-makefiles.
	 * @return true if generation was successful
	 */
	private static boolean generateTop(File maindir) {
		final File mainmake = new File(maindir, "Makefile");
		try {	
			generating(mainmake);
			
			final File[] subdirs = maindir.listFiles(new FileFilter() {
				public boolean accept(File file) {
					return file.isDirectory();
				}});
			
			if (subdirs.length==0) {
				failed(mainmake, "no directories with native implementations found");
				return false;
			}
			
			final PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(mainmake)));
			
			// subdirectories
			out.print("SUBDIRS = ");
			for(File sub: subdirs) {
				if (generate(sub)) {
					out.print(sub.getName());
					out.print(" ");
				}
			}
			
			out.println();
			
			out.println("TARGET = ");
			out.println(".PHONY:  $(SUBDIRS) all clean");
			out.println();
			
			out.println("$(SUBDIRS):");
			out.println("\t$(MAKE) -C $@ $(TARGET)");
			out.println();
			
			out.println("all: TARGET = all");
			out.println("all: $(SUBDIRS)");
			out.println();
			
			out.println("clean: TARGET = clean");
			out.println("clean: $(SUBDIRS)");
			
			out.println();
			out.close();
			done(mainmake);	
			
			
			return true;
		} catch (IOException e) {
			failed(mainmake, e.getMessage());
			return false;
		}
	}
	
	/**
	 * Extracts the main directory argument or uses the default directory if none is specified.
	 */
	private static Map<String, String> processArgs(String[] args) {
		if (args.length%2==1)
			usage();
		final Map<String, String> flags = new HashMap<String, String>(2);
		flags.put("-d", System.getProperty("user.dir"));
		for(int i = 0; i < args.length; i+=2) {
			if (flags.containsKey(args[i]))
				flags.put(args[i], args[i+1]);
			else
				usage();
		}
		return flags;
	}
	
	/**
	 * Prints usage info.
	 */
	private static void usage() {
		System.out.println("Usage: java nativesolver.Make -d <nativesolver directory>");
		System.exit(1);
	}
	
	/**
	 * Usage: java zchaff.Make -d <nativesolver directory>
	 * @effects generates and runs  makefiles for creating JNI libraries for 
	 * the available variants of zchaff.
	 */
	public static void main(String[] args) {

		final File maindir = (new File(processArgs(args).get("-d"))).getAbsoluteFile();
		if (!generateTop(maindir)) return;

		try {
			System.out.println("# make -C "	+ maindir.getAbsolutePath() + " all");
			Process p = Runtime.getRuntime().exec("make -C "	+ maindir.getAbsolutePath() + " all");
			BufferedReader pOutput = new BufferedReader(new InputStreamReader(p.getInputStream()));
			BufferedReader pError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
			int outcome = p.waitFor();
			String line = null;
			while ((line = pOutput.readLine()) != null) { 	System.out.println("# " + line); }
			while ((line = pError.readLine()) != null) { System.err.println("# " + line); }
			System.out.println();
			System.err.println();
			if (outcome == 0) {
				System.out.println("# Created the libraries: " + JLIBDIR);
			} else {
				System.out.println("# Error running make; try running it manually.");
			}
		} catch (IOException e) {
			System.out.println("# Error running make; try running it manually.");
		} catch (InterruptedException e) {
			System.out.println("# Error running make; try running it manually.");
		}
	}

}
