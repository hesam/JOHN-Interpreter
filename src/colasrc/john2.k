
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											     ;;;
;;;  JOHN Language Interpreter -                     					     ;;;
;;;                                                               			     ;;;
;;;  JOHN 2 uses Kodkod to solve the goals of objects       	                             ;;;
;;;  (http://www.advicetaker.org/pmwiki/pmwiki.php)                                          ;;;
;;;                                                               			     ;;;
;;;  COLA Version: running directly on COLA objects					     ;;;
;;;                                                               			     ;;;
;;; Author:        Hesam Samimi                                   			     ;;;
;;;                                                               			     ;;;
;;; Revision:      # 1.0                                      			             ;;;
;;; Last Update:   04-23-2009								     ;;; 
;;;                                                               			     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											     ;;;
;;; Instructions:								 	     ;;;
;;;   1. Start your program with line:							     ;;;
;;;         { john-program }								     ;;;
;;;   2. Run the interpreter, replacing <program filename> to the full name of your program: ;;;
;;;   	 (the dash at the end needed for interactive interpreter upon loading of your file)  ;;;
;;;   	    idst/function/jolt2/main idst/function/jolt2/boot.k john2.k <program filename> - ;;;
;;;   3. To start interactive after running the file, in cola interpreter type:              ;;;
;;;   	    { john-program }    	    	    		 		             ;;;
;;;   	     		 					       			     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; importing define-type into jolt2 from jolt ;; fixme
(load "define-type.k")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some low level constructs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TheGlobalEnvironment (import "TheGlobalEnvironment")) ;; use to do defines from non-global scope
(define IdentityDictionary (import "IdentityDictionary"))
(define Dictionary (import "Dictionary"))
(define Set (import "IdentitySet"))
(define List (import "OrderedCollection"))
(define Random (import "Random"))
(define Integer (import "Integer"))
(define Symbol (import "Symbol"))
(define Date (import "Date"))

;; interpreter settings
(define john-opts [IdentityDictionary new])
[john-opts at: 'max-time-ahead put: '5] ;; max search tree depth to go
[john-opts at: 'auto-draw put: 0] ;; if set to an object, draws that object upon an action
[john-opts at: 'two-player-game put: 0] ;; if set, does minimax searches (for 2-player games)
[john-opts at: 'solver put: '"MiniSat"] ;; solver engine used 
[john-opts at: 'solver-cmd-line put: '"java -cp /Users/hesam/Desktop/Research/tools/Kodkod/kodkodi-1.1.4/jar/kodkodi-1.1.4.jar:/Users/hesam/Desktop/Research/tools/Kodkod/kodkodi-1.1.4/jar/antlr-runtime-3.1.1.jar:/Users/hesam/Desktop/Research/tools/Kodkod/kodkodi-1.1.4/../kodkod.jar -Djava.library.path=/Users/hesam/Desktop/Research/tools/Kodkod/kodkodi-1.1.4/../x86-mac de/tum/in/isabelle/Kodkodi/Kodkodi < "] ;; cmdline for solver

;; constants
(define john-pipes '"|")
(define john-colons '":")
(define john-braces [Array with: '"{" with: '"}"])
(define john-brackets [Array with: '"[" with: '"]"])
(define john-parens [Array with: '"(" with: '")"])
(define john-bracketsSym [Array with: ['"[" asSymbol] with: ['"]" asSymbol]])

;; booleans, etc.
(define john-true [0 = 0]) ;; fixme
(define john-false 0)
(define john-yes 'yes)
(define john-no 'no)
(define john-nil 0)
(define john-ok 'ok.)
(define john-error 'violation!)
(define john-max-int '99) ;; fixme
(define john-primitive-types 
  (let ((a [Array new: '4]))
    [a at: '0 put: [Array with: 'Integer with: Integer]]
    [a at: '1 put: [Array with: 'Word with: Symbol]]
    [a at: '2 put: [Array with: 'List with: List]]
    [a at: '3 put: [Array with: 'Set with: Set]]
    a))

;; globals
;; resolves objects having each other as a property
(define circularObjDefs [IdentityDictionary new])
;; for mw that are for 2-player-games, remembers opponents obj's for minimax search purposes
(define twoPlayerGameOpps [IdentityDictionary new])

;; information used for compiling solver input
(define solverInfo [IdentityDictionary new])

[solverInfo at: 'solver put: [john-opts at: 'solver]]
[solverInfo at: 'solver-cmd-line put: [john-opts at: 'solver-cmd-line]]
[solverInfo at: 'objects put: [OrderedCollection new]]
[solverInfo at: 'vars put: [IdentityDictionary new]]
[solverInfo at: 'varTypes put: [IdentityDictionary new]]
[solverInfo at: 'bounds put: (let ((d [IdentityDictionary new])) [d at: 'Integer put: '0] d)]
;; to remember which msg sends should use compiled_<name> versions of qualifications:
[solverInfo at: 'compiled-msg-sends put: [IdentityDictionary new]]
[solverInfo at: 'oopta put: [IdentityDictionary new]] ;; encoding from oop program to atom univ
[solverInfo at: 'atoop put: [IdentityDictionary new]] ;; decoding from atom univ to oop program


;; internal flags
(define john-minimize 'john-minimize)
(define john-maximize 'john-maximize)
(define john-establish 'john-establish)

;; user msgs
(define john-msg-looking_1 '"looking ")
(define john-msg-looking_2 '" time unit ahead (")
(define john-msg-looking_3 '" possible worlds)")
(define john-msg-already-satisfied '"already satisfied.")
(define john-msg-not-satisfiable '"not satisfiable!")
(define john-msg-satisfied_1 '"satisfied at time: ")
(define john-msg-satisfied_2 '"satisfied by: ")
(define john-msg-timeout '"ok I hear the cpu fan... giving up!")
(define john-msg-consulting '"consulting heuristics... ")

;; pronouns
(define john-it 'self)
(define john-which 'john-which)

;; utilities
(define johnRandomGen [Random new])
(define johnTimer [Date new])
(define startTime 0) 
(define finishTime 0)

;; junk
(define self 0)
(define johnKB 0)
(define johnCurrently 0)

;; internal classes

;; whole knowledge base: containing all micro worlds plus a working memory called currently
;; which remembers the worlds (situation) of the current micro world (the dynamic stuff)
(define-type KnowledgeBase Object (name microWorlds workingMemory))

;; this stores anything about current, including the current micro world in context, etc.
;; doCaching flag: if true, qualification values cached (automatically turned off while 
;; action consequences being applied)
(define-type WorkingMemory Object (name currentMicroWorld currentWorld worlds doCaching))

;; a micro world: containing all classes in it
(define-type MicroWorld Object (name groups classes instances typeQualifications))

;; a class in some micro world: containing property names and all instances
(define-type MicroWorldClass Object (name className microWorld propertyNames groups actions goals instances))

;; an object belonging to a class in some micro world: containing a reference to its class
(define-type MicroWorldObject Object (name class))

;; group of classes
(define-type MicroWorldClassGroup MicroWorldObject (members))

;; a world (situation) at time t is a dictionary that maps an instance name to a dictionary
;; that maps a property name to a property value
;; children is a cache of possible worlds that this world can lead into keyed by unit time apart
;; from this world's time
;; fixme: should children cache be cleared upon an action?
;; causingAction is the action that was run that led to this world
(define-type World Object (time parent children causingAction instancePropertyValues)) 

;; an action of a class in the micro world
;; argCheckExpr is a hack fixme to remember the piece of code checking whether the action should run 
;; a search or not (case when called w/o params)
;; hasOptimizations [ <dynamic/static>, <establish/use> ]:
;;                  <dynamic/static>:
;;                  1 for dynamic (applied at every time level in future), 0 for static
;;                  <establish/use>:
;;                  when 1: use type: a list expression that explicitly says what possible param combinations to use dynamically
;;                  when 0: establish type: a predicate to filter all possible parameters for the action dynamically
;;                  when false: no optimizations, all possible combinations tried
(define-type Action Object (name class variableClasses variableNames rules consequence hasOptimizations argCheckExpr allOptimizationsExpr))

;; a goal of a class in the micro world
;; heuristics are used to decide between worlds when goal is not satisfied
;; hasOptimizations when true: used to decide between which actions to use for satisfying the goal
;; variables are split into their classes and names because of cases where more than one variable
;; of the same class are used (in such case <class name>:<variable name> format is used for the var)
;; allHeuristicsExpr is current hack fixme to build the piece of code that tries and averages scores
;; from all defined heuristics.
;; allOptimizationsExpr is a current hack fixme to build the code that tries each optimization and
;; adds its action to the possible action run list if its predicate is true
(define-type Goal Object (name class variableClasses variableNames predicate heuristics hasOptimizations hasSatOptimizations allHeuristicsExpr allOptimizationsExpr allSatOptimizationsExpr))

;; a heuristic for a goal of a class in the micro world
;; currently 3 types: 1. "maximize", 2. "minimize" (an expr), or 3. "establish" (a predicate) 
(define-type GoalHeuristic Object (goal type weight expression))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define [Object understands: selector]
  (let ((current [self _vtable]) (result 0) (stop [[Object _vtable] delegate]))
    (while (and [current ~= stop] [result not])
	   (set result [current findKeyOrNil: selector])
	   (set current [current delegate]))
    result))

(define [Object isSet] 0)
(define [Set isSet] 1)

(define [Object putln: n]
  (let ((i '0))
    (while [i < n]
	   [self putln]
	   (set i [i + '1]))))

(define [Object put: n]
  (let ((i '0))
    (while [i < n]
	   [self put]
	   (set i [i + '1]))))

(define [Object copy]
  (let ((res [self new]))
    (set res self)
    res))

(define [OrderedCollection atAll: indices]
  (let ((newOrderedCollection [self new])
	(copyFn (lambda (elm args) [[args at: '1] add: [[args at: '0] at: elm]])))
    [indices doFn: copyFn args: [Array with: self with: newOrderedCollection]]
    newOrderedCollection))

(define [Object toString]
  [self asString])

(define [List toString]
  (let ((res '"[ ") (i '0) (s [self size]))
    (while [i < s]
	   (set res [res , [[self at: i] asString]])
	   (set i [i + '1])
	   (if [i < s] (set res [res , '", "])))
    [res , '" ]"]))

(define [OrderedCollection toSymbol]
  [self accumulate: (lambda (elm val) (set val (if val [[val , elm] , '":"] [elm , '":"])))
	init: 0 arg: 0])

(define [OrderedCollection filterBy: pred args: args]
  (let ((res [self new])
	(filterFn (lambda (elm args) (if ([args at: '0] elm [args at: '1]) [[args at: '2] add: elm]))))
    [self doFn: filterFn args: [Array with: pred with: args with: res]]
    res))

;; collection: (a b), collection: (1 2) ---> dict: a->1, b->2 
(define [OrderedCollection toDictionary: vals]
  (let ((index '0) (dict [IdentityDictionary new]) 
	(fn (lambda (elm1 elm2 args) [args at: elm1 put: elm2])))
    [self and: vals doFn: fn args: dict]
    dict))

(define [OrderedCollection from: f to: t]
  (let ((newOrderedCollection [self new]) (i f))
    (while (<= i t)
	   (let ((item [self at: i]))
	     [newOrderedCollection add: item])
	   (set i [i + '1]))
    newOrderedCollection))

(define [OrderedCollection from: f]
  [self from: f to: [[self size] - '1]])

(define [OrderedCollection to: f]
  [self from: '0 to: f])

;; returns a new collection resulted from running a collection of messages (msgs) 
;; recursively on each element in the original collection
(define [OrderedCollection applyMsgsAndMap: msgs]
  (let ((res [OrderedCollection new]) 
	(fn (lambda (elm args) (let ((res elm) (j '0) (msgs [args at: '0]))
				 (while (< j [msgs size])
					(set res [res perform: [msgs at: j]])
					(set j [j + '1]))
				 [[args at: '1] add: res]))))
    [self doFn: fn args: [Array with: msgs with: res]]
    res))

;; normal map
(define [OrderedCollection mapMsg: msg]
  [self mapMsg: msg withArguments: [OrderedCollection new]])

;; normal method call map
(define [OrderedCollection mapMsg: msg withArguments: args]
  (let ((res [OrderedCollection new]) 
	(fn (lambda (elm args) [[args at: '1] add: [elm perform: [args at: '0] withArguments: [args at: '2]]])))
    [self doFn: fn args: [Array with: msg with: res with: args]]
    res))

;; returns a new collection resulted from running a collection of messages (msgs) 
;; recursively on each element in the original collection
(define [OrderedCollection applyMsgsAndAppend: msgs]
  (let ((res [OrderedCollection new]) 
	(fn (lambda (elm args) (let ((res elm) (j '0) (msgs [args at: '0]))
				 (while (< j [msgs size])
					(set res [res perform: [msgs at: j]])
					(set j [j + '1]))
				 [[args at: '1] addAll: res]))))
    [self doFn: fn args: [Array with: msgs with: res]]
    res))

(define [IdentityDictionary values]
  (let ((res [OrderedCollection new]) 
	(fn (lambda (elm args) [[args at: '1] add: [[args at: '0] at: elm]])))
    [[self keys] doFn: fn args: [Array with: self with: res]]
    res))

(define [OrderedCollection extremum: op]
	(let ((ans [Array with: [self at: '0] with: op]))
	     [self doFn: (lambda (elm args) (if ([args at: '1] elm [args at: '0]) [args at: '0 put: elm])) 
		   args: ans]
	     [ans at: '0]))

(define [OrderedCollection min]
  [self extremum: (lambda (a b) (< a b))])

(define [OrderedCollection max]
  [self extremum: (lambda (a b) (> a b))])

(define [OrderedCollection indices]
  (let ((i '0) (res [OrderedCollection new]))
    (while [i < [self size]] [res add: i] (set i [i + '1]))
    res))

(define [OrderedCollection lastIndex]
  [[self size] - '1])

;; returns the keys in dictionary with min or max value
;; isMin should be set to true for min case, false for max case
(define [IdentityDictionary keysWithExtremum: isMin]
  (let ((myKeys [self keys]) (i '0) (extremum 0) (ansKeys [OrderedCollection new]))
    (while (< i [myKeys size])
	   (if (or (not extremum) (or (and isMin [[self at: i] < extremum])
				      [[self at: i] > extremum]))
	       (let ()
		 (set ansKeys [OrderedCollection with: i])
		 (set extremum [self at: i]))
               (if [[self at: i] = extremum]
		   [ansKeys add: i]))
	   (set i [i + '1]))
    ansKeys))

(define [Set copy]
  [Set withAll: [self elements]])

(define [Set mapMsg: msg]
  [Set withAll: [[self elements] mapMsg: msg]])

(define [Set mapMsg: msg withArguments: args]
  [Set withAll: [[self elements] mapMsg: msg withArguments: args]])

(define [Set at: i]
  [[self elements] at: i])

(define [Set + set2]
  (let ((set2Elms (if [set2 isSet] 
		      [[set2 elements] copy] 
		      [OrderedCollection with: set2])))
    [Set withAll: [[[self elements] copy] addAll: set2Elms]]))

(define [List + list2]
  (let ((list2Elms (if [list2 isSequenceableCollection] 
		       [list2 copy] 
		       [OrderedCollection with: list2])))
    [List withAll: [[self copy] addAll: list2Elms]]))

(define [Set removeAll: elms ifAbsent: errBlk]
  [elms doFn: (lambda (elm set) (if [set includes: elm] [set remove: elm ifAbsent: 0]))
	         args: self])

(define [List removeAll: elms ifAbsent: errBlk]
  [elms doFn: (lambda (elm list) (if [list includes: elm] [list remove: elm ifAbsent: 0]))
	args: self])

(define [List rest]
  (let ((res [self copy]))
    [res removeFirst]
    res))

(define [List sum]
  [self accumulate: (lambda (elm val) (set val [val + elm])) init: '0 arg: 0])

;; converts list to set
(define [List unique]
	[Set withAll: self])

(define [Set = s]
  (and [s isSet]
       (let ((elms [self elements]))
	 (and (== [[s elements] size] [elms size])
	      (let ((i '0))
		(while [i < [elms size]]
		       (if (not [s includes: [elms at: i]]) (return 0))
		       (set i [i + '1]))
		john-true)))))

(define [SmallInteger to: upper]
  (let ((s [[upper - self] + '1]) (res [Array new: s]) (i '0))
    (while [i < s]
	   [res at: i put: [i + self]]
	   (set i [i + '1]))
    res))
    
(define [List count: item]
  (let ((i '0) (res '0))
    (while [i < [self size]]
	   (if [[self at: i] = item] (set res [res + '1]))
	   (set i [i + '1]))
    res))

(define [List includes: item]
  (let ((i '0))
    (while [i < [self size]]
	   (if [[self at: i] = item] (return john-true))
	   (set i [i + '1]))
    0))

(define [Set includes: item]
  [[self elements] includes: item])

(define [Set - set2]
  (let ((res [self copy])
	(set2Elms (if [set2 isSet] 
		      [set2 elements]
		      [OrderedCollection with: set2])))
    [res removeAll: set2Elms ifAbsent: 0]
    res))

(define [List - list2]
  (let ((res [self copy])
	(list2Elms (if [list2 isSequenceableCollection] 
		       list2
		       [OrderedCollection with: list2])))
    [res removeAll: list2Elms ifAbsent: 0]
    res))

;; returns a new set with elements of cross product of this and that set
(define [Set * set2]
  [[self elements] * [set2 elements]])

;; returns a new list with elements of cross product of this and that list
;; [a b] [2 3] --> [[a 2] [a 3] [b 2] [b 3]]
(define [List * c2] 
  (let ((res [self new]) (i '0) (j '0))
    (while [i < [self size]]
	   (set j '0)
	   (while [j < [c2 size]]
		  [res add: [self with: [self at: i] with: [c2 at: j]]]
		  (set j [j + '1]))
	   (set i [i + '1]))
    res))

;; [[a b] [c d]] [1 2] --> [[1 a b] [1 c d] [2 a b] [2 c d]]
(define [List insertAtFronts: c2]
  (let ((res [self new]) (i '0) (j '0))
    (while [i < [self size]]
	   (set j '0)
	   (while [j < [c2 size]]
		  [res add: [self with: [c2 at: j] withAll: [self at: i]]]
		  (set j [j + '1]))
	   (set i [i + '1]))
    res))

;; [[a b]] --> [[a] [b]]
;; [[a b] [2 3]] --> [[a 2] [a 3] [b 2] [b 3]]
;; [[0 1] [a b] [2 3]] --> [[0 a 2] [0 a 3] ... ]
(define [List crossProduct] 
  (let ((s [self size]))
    (if [s < '2]
	(let ((r [self new]))
	  [[self first] doFn: (lambda (e args) [args add: [List with: e]]) args: r] r)
	(if [s = '2]
	    [[self first] * [self second]]
	    (let ((rcp [[self rest] crossProduct]))
	      [rcp insertAtFronts: [self first]])))))

(define [OrderedCollection accumulate: fn init: val arg: one]
  (let ((i '0))
    (while [i < [self size]]
	   (set val (fn [self at: i] val one))
	   (set i [i + '1]))
    val))

(define collection-do 
  (lambda (collection fn args)
    (let ((i '0))
      (while [i < [collection size]]
	     (fn [collection at: i] args)
	     (set i [i + '1]))
      john-ok)))

(define collections-do 
  (lambda (collection anotherCollection fn args)
    (let ((i '0))
      (while [i < [collection size]]
	     (fn [collection at: i] [anotherCollection at: i] args)
	     (set i [i + '1]))
      john-ok)))

(define collection-do-with-break 
  (lambda (collection fn args retValFlag initRetVal)
    (let ((i '0))
      (while [i < [collection size]]
	     (let ((retVal (fn [collection at: i] args)))
	       (if (== retVal retValFlag)
		   (return retVal)))
	     (set i [i + '1]))
      initRetVal)))

(define [Array doFn: fn args: vals]
  (collection-do self fn vals))

(define [OrderedCollection doFn: fn args: vals]
  (collection-do self fn vals))

(define [OrderedCollection doFn: fn args: vals breakWhen: retVal initVal: init]
  (collection-do-with-break self fn vals retVal init))

(define [Array and: c doFn: fn args: vals]
  (collections-do self c fn vals))

(define [OrderedCollection and: c doFn: fn args: vals]
  (collections-do self c fn vals))

(define [Set doFn: fn args: vals]
  (collection-do [self elements] fn vals))

(define [Set doFn: fn args: vals breakWhen: retVal initVal: init]
  (collection-do-with-break [self elements] fn vals retVal init))

;; get a num size random subset out of collection
(define [OrderedCollection random: num] 
  (let ((x [Random next]) (mySize [self size]) (maxInd [mySize - '1])
	(n [Random nextInt: mySize]) (subset [Set new]))
    (if [num > mySize]
	john-nil
	(let ((mem [IdentityDictionary new]))
	  (while [[[subset elements] size] < num]
		 (while [mem includesKey: n]			     	   
			(set n [[n + [Random nextInt: mySize]] \\ mySize]))
		 [mem at: n put: '1]
		 [subset add: [self at: n]])
	  subset))))

(define [OrderedCollection randomOne]
  (let ((n [johnRandomGen nextInt: [self size]]))
    (if [[self size] = '0] john-nil [self at: n])))

(define [Set random: num]
  [self withAll: [[self elements] random: num]])

(define [Set randomOne]
  [[self elements] randomOne])

(define [Object draw]
  [self printMe])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; John code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define [Object isMicroWorldClass]
  john-false)

(define [MicroWorldClass isMicroWorldClass]
  john-true)

(define [Object printMeHelper]
  (let ((p (if (== self john-false) john-no (if (== self john-true) john-yes self)))) ;; fixme
    [p asString]))

(define [Object printlnMe]
  [[self printMeHelper] putln])

(define [Object printMe]
  [[self printMeHelper] put])

(define [MicroWorldObject printlnMe]
  [[self name] printlnMe])

(define [MicroWorldObject printMe]
  [[self name] printMe])

(define [Set printlnMe]
  [self printlnMeHelper: 1])

(define [Set printMe]
  [self printlnMeHelper: 0])

(define [Set withAll: elms]
  (let ((res [Set new: [elms size]]))
    [res addAll: elms]
    res))

(define [Set elements]
  (let ((lists [self lists]) (res [OrderedCollection new])
	(printFn (lambda (elm args) (if elm [elm doFn: (lambda (elm2 args2) 
							 (if elm2 [args2 add: elm2]))
						 args: args]))))
    [lists doFn: printFn args: res]
    res))

(define [Set printlnMe]
  [[self elements] printlnMeHelper: 1 boundSyms: john-braces])

(define [Set printMe]
  [[self elements] printlnMeHelper: 0 boundSyms: john-braces])

(define [List printlnMe]
  [self printlnMeHelper: 1 boundSyms: john-brackets])

(define [List printMe]
  [self printlnMeHelper: 0 boundSyms: john-brackets])

(define [List printlnMeHelper: nl boundSyms: bs]
  (let ((printFn (lambda (elm args) 
		   (let ()
		     (if [args first] ['", " put]) 
		     [args at: '0 put: 1]
		     [elm printMe]))))
    [[bs at: '0] put] 
    ['" " put]
    [self doFn: printFn
	  args: [Array with: 0]]
    ['" " put] (if nl [[bs at: '1] putln] [[bs at: '1] put])))

(define [Object johnEval]
  [self _eval])

(define [Symbol + sym]
  [self , sym])

;; two string concated give symbol (useful)
(define [String + str]
	[[self asSymbol] , [str asSymbol]])

(define [Symbol * n]
  (let ((i '1) (res self))
    (while [i < n]
	   (set res [res , self])
	   (set i [i + '1]))
    res))

(define [String * n]
	[[self asSymbol] * n])

;; returns the object with its name
(define [Symbol object]
  (let ((res [johnKB getObject: self]))
    (if res res self)))

(define [String name]
	[self asSymbol])

(define [String object]
	[[self asSymbol] object])

(define [Symbol isCapitalized]
  (let ((f [self at: '0]))
    (and [f > '64 ] [f < '91])))

;; hack fixme: 'name' had a clash with [microworldobject name] or internal jolt msg?
(define [Object namer]
  self)

(define [Object isMicroWorldObject]
	0)

(define [MicroWorldObject isMicroWorldObject]
	1)

(define [MicroWorldObject namer]
  [self name])

(define [MicroWorldObject set: propName value: propVal]
  (let ()
    [johnCurrently advanceTime: [List new: '0]]
    [[johnCurrently currentWorld] update: self property: propName value: propVal]
    john-ok))

(define [Integer asSymbol]
	self)

(define [Integer % num]
  [self \\ num])

(define [Integer ** num]
  (let ((ans '1))
    (while [num > '0]
	   (set ans [ans * self])
	   (set num [num - '1]))
    ans))

(define [Integer ceilLogn: n] 
  (let ((i '1) (res '1))
    (while [i < self]
	   (set i [i * n])
	   (set res [res + '1]))
    res))

;; avoids need for conditions...
(define [Integer errorDivisionByZero]
  '0)

;; returns a list of num random numbers less than this number
(define [Integer random: num] 
  (let ((x [Random next]) (subset [List new]) (i '0))
    (while [i < num]
	   [subset add: [Random nextInt: self]]
	   (set i [i + '1]))
    subset))

;; methods for internal classes

(define [World withTime: time]
  (let ((w [self new]))
    [w time: time]
    [w children: [IdentityDictionary new]]
    [w instancePropertyValues: [IdentityDictionary new]]
    w))

(define [World update: obj property: propertyName value: propertyValue]
  (let ((objName [obj namer]) (solverInfoVars [solverInfo at: 'vars]) 
	(var [[objName , '.] , propertyName])
	(instancesPropNamesValsDict [self instancePropertyValues])
	(instPropVals [instancesPropNamesValsDict at: objName
					 ifAbsentPut: [IdentityDictionary new]]))
    [instPropVals at: propertyName put: propertyValue]))

(define [World cache: obj property: propertyName value: propertyValue]
  (if [johnCurrently doCaching]
      [self update: obj property: propertyName value: propertyValue]
      0))

(define [World getParentAtTime: time]
  (let ((targetWorld self))
    (while [time < [targetWorld time]]
	   (set targetWorld [targetWorld parent]))
    targetWorld))

;; gets path (of actions done) from an ancestor world to this world
(define [World getPathFromWorld: ancestor]
  (let ((targetWorld self) (time [ancestor time]) (res [List new]))
    (while [time < [targetWorld time]]
	   [res addFirst: [[targetWorld causingAction] toString]]
	   (set targetWorld [targetWorld parent]))
    res))
  
;; reduces cached stored children of a world (possible worlds n time unit from it) 
;; by prunning all children except for the branch of the given world
(define [World pruneChildrenTo: pickedNextWorld]
  (let ((timeAhead '2))
    [[self children] at: '1 put: [OrderedCollection with: pickedNextWorld]]
    (while [[self children] includesKey: timeAhead]		    
	   [[self children] at: timeAhead
	    put: [[pickedNextWorld children] at: [timeAhead - '1]]]
	   (set timeAhead [timeAhead + '1]))))

;; returns collection of possible worlds one time unit from now (by trying all possible actions)
(define [World getNextPossibleWorldsByPossibleActionRuns: possibleActionRuns isForGoal: goal isForAction: usingActions andObj: theObj hasOpt: hasOpt isTwoPlayerAndOppTurn: isTwoPlayerAndOppTurn]
  (let ((wm johnCurrently) (currWorld [wm currentWorld]) 
	(possibleWorlds [OrderedCollection new]))
    ;; runs each action possibility and adds the resulting worlds when they succeed
    ;; then restoring the current world pointer as if no actions has been done:
    (let ((runFn (lambda (elm args)	  
		   (let ((ret [[elm first] perform: [elm second] 
			       withArguments: [elm third]]))
		     (if ret
			 (let ((wm [args at: '0]))
			   [[args at: '1] add: [wm currentWorld]]
			   [wm currentWorld: [args at: '2]]))))))
      [wm currentWorld: self]
      ;; reduce possible actions to try when this is for a goal and 
      ;; it has optimizations defined.
      (if (and goal [goal hasSatOptimizations])
	    (set usingActions (send 'getPossibleActionsByGoalOptimizations theObj)))
      ;; also reduce possible action parameter combinations to try when this is for a goal using
      ;; a particular action which has dynamic optimizations defined
      (if hasOpt
	  (set possibleActionRuns [[johnCurrently currentMicroWorld] 
				   getPossibleActionRunsBy: [OrderedCollection with: theObj] 
				   using: usingActions]))
      
      [possibleActionRuns doFn: runFn 
			  args: [Array with: wm with: possibleWorlds with: self]]

      ;; fixme? still broken?
      ;; if this is a two-player-game and its opp turn (minimax), we should only
      ;; consider opponent's best moved (based on defined goal heuristics) for each
      ;; of player's moves:
      (if isTwoPlayerAndOppTurn
	  (set possibleWorlds
	       (send 'pickFromPossibleWorldsByHeuristics 
		     isTwoPlayerAndOppTurn goal possibleWorlds)))

      [[self children] at: '1 put: possibleWorlds]
      ;; cache these for my parents as grand children...
      (let ((ancestor self) (cacheTime '1))
	(while [[ancestor time] > '0]
	       (set cacheTime [cacheTime + '1])
	       (set ancestor [ancestor parent])
	       (let ((ancestorpwCache [[ancestor children] at: cacheTime 
				       ifAbsentPut: [OrderedCollection new]]))
		 [ancestorpwCache addAll: possibleWorlds])))
      [wm currentWorld: currWorld]
      possibleWorlds)))

;; WorkingMemory has a dictionary of possible worlds for each time, so its worlds is a dictionary
;; of dictionaries
(define [WorkingMemory withName: name]
  (let ((cm [self new]) (w0 [World withTime: '0]) (wlds [IdentityDictionary new]))
    [cm name: name]
    [cm currentWorld: w0]
    [wlds at: '0 put: w0]
    [cm worlds: [IdentityDictionary new]]
    [cm doCaching: john-true]
    [[cm worlds] at: '0 put: wlds]
    ;; johnCurrently: current working-memory
    (set johnCurrently cm)
    cm))

;; creates a new world to move one unit in time forward, updates the CurrentWorld
;; in the new world, records which action resulted in this new world.
;; a new world is created everytime an action is about to happen
(define [WorkingMemory advanceTime: actionDescr]
  (let ((newTime [[[self currentWorld] time] + '1])
	(newCurrWorld [World withTime: newTime]) (possibleWorlds [IdentityDictionary new]))
    [newCurrWorld parent: [self currentWorld]]
    [newCurrWorld causingAction: actionDescr]
    [possibleWorlds at: '0 put: newCurrWorld]
    [[self worlds] at: newTime put: possibleWorlds]
    [self currentWorld: newCurrWorld]))

;; helper for the one below
(define [WorkingMemory getPossibleWorldsIn_h: timeAhead lastCachedTime: lastCachedTimeAhead lastCachedTimepws: lastCachedpws byPossibleActionRuns: possibleActionRuns isTwoPlayerGame: isTwoPlayerGame oppObj: oppObj byOpponentPossibleActionRuns: oppPossibleActionRuns isOppTurn: isOppTurn isForGoal: goal isForAction: usingActions andObj: theObj hasOpt: hasOpt]
  (if [lastCachedTimeAhead = timeAhead]
      lastCachedpws
      (let ((currWorld [self currentWorld]) (currTime [currWorld time]) 
	    (targetTime [currTime + timeAhead]) 
	    (isTwoPlayerAndOppTurn (if (and isTwoPlayerGame isOppTurn) oppObj 0))
	    (currObj (if isTwoPlayerAndOppTurn oppObj theObj))
	    (finalPossibleActionRuns (if isTwoPlayerAndOppTurn
					 oppPossibleActionRuns
					 possibleActionRuns)))
	(let ((possibleWorlds [OrderedCollection new])
	      (oneAway [[lastCachedTimeAhead + '1] = timeAhead]) (i '0))
	  (while [i < [lastCachedpws size]]
		 (let ((wld [lastCachedpws at: i])
		       (nextpws [wld getNextPossibleWorldsByPossibleActionRuns: finalPossibleActionRuns isForGoal: goal isForAction: usingActions andObj: currObj hasOpt: hasOpt isTwoPlayerAndOppTurn: isTwoPlayerAndOppTurn]))
		   ;; temporarily make this world the current world and get its next 
		   ;; children (possible worlds in one time unit) 
		   [self currentWorld: wld]
		   (let ((thisWldpws [self getPossibleWorldsIn_h: [timeAhead - '1] lastCachedTime: lastCachedTimeAhead lastCachedTimepws: nextpws byPossibleActionRuns: possibleActionRuns isTwoPlayerGame: isTwoPlayerGame oppObj: oppObj byOpponentPossibleActionRuns: oppPossibleActionRuns isOppTurn: (not isOppTurn) isForGoal: goal isForAction: usingActions andObj: theObj hasOpt: hasOpt]))
		     [possibleWorlds addAll: thisWldpws]))
		 [self currentWorld: currWorld]
		 (set i [i + '1]))
	  possibleWorlds))))

;; returns collection of possible worlds nth time unit from now (by trying all possible actions)
(define [WorkingMemory getPossibleWorldsIn: timeAhead byPossibleActionRuns: possibleActionRuns isTwoPlayerGame: isTwoPlayerGame byOpponentPossibleActionRuns: oppPossibleActionRuns isForGoal: goal isForAction: usingActions andObj: theObj hasOpt: hasOpt]
  (let ((currWorld [self currentWorld]) (currTime [currWorld time]) 
	(targetTime [currTime + timeAhead]) (mw [self currentMicroWorld]))
    
    ;; check if possible worlds at targetTime is already calculated:
    (if [[currWorld children] includesKey: timeAhead]
	(return [[currWorld children] at: timeAhead]))
    
    (let ((oppObj (if isTwoPlayerGame [twoPlayerGameOpps at: [theObj name]] 0))	
	  (lastCachedTimeAhead timeAhead))
    (while (and [lastCachedTimeAhead > '0]
		(not [[currWorld children] includesKey: lastCachedTimeAhead]))
	   (set lastCachedTimeAhead [lastCachedTimeAhead - '1]))
    (let ((lastCachedpws (if [lastCachedTimeAhead = '0]
			     [OrderedCollection with: currWorld]
			     [[currWorld children] at: lastCachedTimeAhead]))
	  (possibleWorlds [self getPossibleWorldsIn_h: timeAhead
				lastCachedTime: lastCachedTimeAhead
				lastCachedTimepws: lastCachedpws
				byPossibleActionRuns: possibleActionRuns
				isTwoPlayerGame: isTwoPlayerGame
				oppObj: oppObj
				byOpponentPossibleActionRuns: oppPossibleActionRuns
				isOppTurn: [[lastCachedTimeAhead \\ '2] = '1]
				isForGoal: goal isForAction: usingActions andObj: theObj hasOpt: hasOpt]))
      [[currWorld children] at: timeAhead put: possibleWorlds]
      possibleWorlds))))

;; gets the property value of an object at the requested world
(define [WorkingMemory get: obj property: propertyName world: targetWorld]
  (let ((foundFlag 0) (objName [obj name]))
    ;; we're looking for the world that has this property starting from given 
    ;; world. if not there, go to the parent and parent of parent, so on,
    ;; until we go enough back to find the world that has the most uptodate
    ;; value of this property
    (while (and (not (let ((found (and [[targetWorld instancePropertyValues] 
					includesKey: objName]
				       [[[targetWorld instancePropertyValues] 
					 at: objName] 
					includesKey: propertyName])))
		       (if found (set foundFlag 1))
		       found))
		[targetWorld parent])
	   (set targetWorld [targetWorld parent]))
    (if foundFlag
	[[[targetWorld instancePropertyValues] at: objName] at: propertyName]
	john-nil)))

;; same as above, w/o dynamic scoping
;; return is an array first elm is found flag, second is value
(define [WorkingMemory get: obj property: propertyName exactWorld: targetWorld]
	(let ((objName [obj namer]) (allPropVals [targetWorld instancePropertyValues]))
               (if (and [allPropVals includesKey: objName]
	                [[allPropVals at: objName] includesKey: propertyName])
		   [Array with: 1 with: [[allPropVals at: objName] at: propertyName]]
	           [Array with: 0 with: 0])))

;; gets a set of possible world property values for a property of an object given the possible worlds
(define [WorkingMemory get: obj property: propertyName worlds: possibleWorlds]
	(let ((pwVals [Set new]) 
	      (getPropAtWorld 
	          (lambda (elm args) 
	               [[args at: '1] 
			  add: [[args at: '0] get: [args at: '2] property: [args at: '3] world: elm]])))
	     [possibleWorlds doFn: getPropAtWorld 
	     		     	args: [Array with: self with: pwVals withAll:
	     		     	      	     [Array with: obj with: propertyName]]]
	     pwVals))

;; gets the property value of an object at the requested time
(define [WorkingMemory get: obj property: propertyName time: time]
	(let ((currWorld [self currentWorld]) (currTime [currWorld time])
	      (mw [self currentMicroWorld]))
	      ;; if time is not given, implies current time,
	      ;; if the time is past, just get the property value, 
	      ;; if is future then generate a set of possible world values
	      (if time
	      	  (if [time <= currTime]
		      [self get: obj property: propertyName world: [currWorld getParentAtTime: time]]
		      (let ((timeAhead [time - currTime])
			    (possibleActionRuns [mw getPossibleActionRunsBy: 0 using: 0])
			    (possibleWorlds [self getPossibleWorldsIn: timeAhead byPossibleActionRuns: possibleActionRuns isTwoPlayerGame: 0 byOpponentPossibleActionRuns: 0 isForGoal: 0 isForAction: 0 andObj: 0 hasOpt: 0]))
			['"Possible World values (" put] [timeAhead print]
			['" time unit from now):" putln]
			[self get: obj property: propertyName worlds: possibleWorlds]))
	      	  [self get: obj property: propertyName world: currWorld])))

(define [KnowledgeBase withName: name]
	(let ((kb [self new]))
	     [kb name: name]
	     [kb workingMemory: [WorkingMemory withName: 'currently]]
	     [kb microWorlds: [IdentityDictionary new]]
	     kb))

(define [KnowledgeBase addMicroWorld: newMicroWorldName]	
	(let ((newMicroWorld [MicroWorld new])
	      (classes (let ((c [IdentityDictionary new])) 
		  [john-primitive-types 
		   doFn: (lambda (elm args) [args at: [elm first] put: [elm second]]) 
		   args: c]
		  c)))
	     ;; instantiate a new MicroWorld
	     [newMicroWorld name: newMicroWorldName]
	     (let ((tmp [IdentityDictionary new]))
	       [tmp at: 'classes put: [IdentityDictionary new]]
	       [tmp at: 'groups put: [IdentityDictionary new]]
	       [newMicroWorld groups: tmp])
	     [newMicroWorld classes: classes]
	     [newMicroWorld instances: [IdentityDictionary new]]
	     [newMicroWorld typeQualifications: [IdentityDictionary new]]
	     [[self microWorlds] at: newMicroWorldName put: newMicroWorld]
	     ;; make the current micro world this new one
	     [self workingMemory: [WorkingMemory withName: 'currently]]
	     [[self workingMemory] currentMicroWorld: newMicroWorld]
	     john-ok))

;; gets the class of the current microworld from className
(define [KnowledgeBase getClass: className]
	(let ((classes [[[self workingMemory] currentMicroWorld] classes]))
	     (if [classes includesKey: className]
	     	 [classes at: className]
		 john-nil)))

;; gets the class group of the current microworld from groupName
(define [KnowledgeBase getGroup: groupName]
	(let ((groups [[[[self workingMemory] currentMicroWorld] groups] at: 'groups]))
	  (if [groups includesKey: groupName]
	      [groups at: groupName]
	      john-nil)))

;; gets the class of the current microworld from className
(define [KnowledgeBase getObject: intanceName]
	(let ((instances [[[self workingMemory] currentMicroWorld] instances]))
	     (if [instances includesKey: intanceName]
	     	 [instances at: intanceName]
		 john-nil)))

(define [KnowledgeBase getObjects: intanceNames]
	(let ((res [OrderedCollection new]))
      	     [intanceNames doFn: (lambda (elm args) [args add: [johnKB getObject: elm]]) 
			      args: res]
	     res))

;; all instances of a class
(define [MicroWorld all: aClass name: className]
	(let ((classes [[johnCurrently currentMicroWorld] classes]) 
	      (class (if [classes includesKey: className] [classes at: className] aClass)))
	     [class all]))

(define [MicroWorld all: className getNames: getNames]
  (let ((mw [johnCurrently currentMicroWorld])
	(classOrGroup (if [[mw classes] includesKey: className] 
			  [[mw classes] at: className]
			  [[[mw groups] at: 'groups] at: className])))
    (if getNames [classOrGroup allObjNames] [classOrGroup all])))

(define [MicroWorld allInstances]
	[[[self classes] values] applyMsgsAndAppend: [Array with: 'all]])

(define [MicroWorld allActions]
	[[[self classes] values] applyMsgsAndAppend: [Array with: 'actions with: 'values]])

;; all instances of a list of classes
(define [MicroWorld allOfThese: classNames]
	(let ((res [OrderedCollection new]))
	     [classNames doFn: (lambda (elm args) [[args at: '1] add: [[args at: '0] all: elm name: elm]])
		    	    args: [Array with: self with: res]]
	     res))

;; get all possible actions that objects might do with all combinations of action params
;; default is all actions by all objects, if actors or actions are given, they limit the list...
;; fixme: do the case with limited actors
(define [MicroWorld getPossibleActionRunsBy: actors using: actions]
  (let ((possibleActions (if actions actions [self allActions])) (res [OrderedCollection new])
	(fn (lambda (elm args) [[args at: '0] addAll: [elm possibleRuns: [args at: '1]]])))
    [possibleActions doFn: fn args: [Array with: res with: actors]]
    res))

;; what are all cobinations of actors and action params that this action can be run with
(define [Action possibleRuns: actors]
  (let ((mw [[self class] microWorld])
	(possActors (if actors actors [[self class] all]))
	(actorsAction [OrderedCollection with: possActors 
					 with: [OrderedCollection with: [self name]]])	
	(possParams (if [[[self variableNames] size] = '0] ;; a no variable action
			[OrderedCollection with: [OrderedCollection new]]
			  ;; if this action has optimizations defined which reduce 
			  ;; the list of possible parameters combos, they need to be dynamic
			  ;; cannot determine them here
			(let ((optimizationOpt [self hasOptimizations]))
			  (if (and optimizationOpt [optimizationOpt at: '1]) ;; use type optimization
			      (send ['reducePossibleActionParamsByOptimizationsForAction- , [self name]]
				    [possActors at: '0])
			      (let ((origPossParams [[mw allOfThese: [self variableClasses]] crossProduct]))
				(if optimizationOpt ;; establish type optimization
				    [origPossParams 
				     filterBy: (lambda (paramsTuple args)
						 [[args at: '0] perform: [args at: '1]
						  withArguments: paramsTuple])
				     args: [Array with: [possActors at: '0]
						  with: ['reducePossibleActionParamsByOptimizationsForAction- , [self name]]]]
				    origPossParams))))))
	(precpList [OrderedCollection withAll: actorsAction with: possParams]))
    [precpList crossProduct]))

;; gets all instances of a class
(define [MicroWorldClass all]
  [[self instances] values])

(define [MicroWorldClass getActions: actionNames]
  (let ((res [OrderedCollection new]))
    [actionNames doFn: (lambda (elm args) [[args at: '0] add: [[args at: '1] at: elm]]) 
		 args: [Array with: res with: [self actions]]]
    res))

(define check-auto-draw
  (lambda (retVal)
    (let ((autoDrawObj [john-opts at: 'auto-draw]))
      (if (and autoDrawObj (== retVal john-ok)) 
	  (let () [autoDrawObj draw] [[String lf] put]))
      retVal)))

;; main eval function:
(define eval-sentence
  (lambda (parsed-exp doTime)
    (let ((startTime 0))
      [parsed-exp println]
      (if doTime (set startTime [[johnTimer initialize] seconds])) 
      (let ((v [parsed-exp johnEval])) 
	[v printlnMe]
	(if doTime
	    (let ((finishTime [[johnTimer initialize] seconds])
		  (queryTime [finishTime - startTime]))
	      (if [queryTime ~= '0]
		  (let ((isSec [queryTime < '60])
			(t (if isSec queryTime [queryTime / '60]))
			(u (if isSec '" sec ]" '" min ]")))
		    ['"[ query time: " put] [t print] [u putln]))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; johnKB: whole knowlege-base
(define johnKB [KnowledgeBase withName: 'johnKB])
[johnKB addMicroWorld: 'universe]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(printf "; defining syntax\n")

(syntax begin
	(lambda (node compiler)
	  (let ((exp `(and)) (i '1))
	    (while [i < [node size]]
		   (set exp [Expression withAll: exp with: `(or ,[node at: i] 1)])
		   (set i [i + '1]))
	    (set exp `(if ,exp ',john-ok))
	    `,exp)))

(syntax filter-collection-by
	(lambda (node compiler)
	  `(let ((coll ,[node second]) (res [coll new]) (i '0))
	     (while [i < [coll size]]
		    (let ((elm [coll at: i]) (john-which elm))
		      (if ,[node third] [res add: elm]))
		    (set i [i + '1]))
	     res)))

(define [WorkingMemory eval: exp inWorld: w]
  (let ((currWorld [self currentWorld]))
    [self currentWorld: w]
    (let ((ret [exp johnEval]))
      [self currentWorld: currWorld]
      ret)))

;; temporarily sets current world to the given world and evaluates the expression
(syntax eval-in-world
	(lambda (node compiler)
	  `(let ((wm johnCurrently) (currWorld [wm currentWorld]))
	     [wm currentWorld: ,[node third]]
	     (let ((ret ,[node second]))
	       [wm currentWorld: currWorld]
	       ret))))

(syntax predicate
 	(lambda (node compiler)
	  (let ((pred [node second]))
	    `(if ,pred john-yes john-no))))

;; evaluates a predicate after running an action (runs action, evals pred, reverts action)
					;upon variableExp2->0 do name->1 primitiveValue*->2 do clauses->3
(syntax upon-action-clause
 	(lambda (node compiler)
	  `(eval-in-world (and (send ',[node third] ,[node second] ,@[node fourth])
			       ,[node fifth])
			  [johnCurrently currentWorld])))

(syntax make-collection
	(lambda (node compiler)
	  (let ((i '2) (exp `(let ((collection [OrderedCollection new])))))
	    (while [i < [node size]]
		   (set exp [Expression withAll: exp with: `[collection add: ,[node at: i]]])
		   (set i [i + '1]))
	    (set exp [Expression withAll: exp with: `[,[node second] withAll: collection]])
	    exp)))

;;<all> [<propertyValue> <propertyName>]+? <class name>
;; e.g. all square, all green color tall size lego
;; fixme: add second e.g. case above
(syntax filter-object-list
	(lambda (node compiler)
	  (let ((pred [node third]) 
		(list `[[johnCurrently currentMicroWorld] all: ,[node second] name: ',[node second]]))
	    (if pred `(filter-collection-by ,list ,pred) list))))

;; input: either collection or class name (in which case the implied collection is set of all instaces)
;; type: '0 -> this is already a collection, 
;;       '1 -> this is a class name, the collection is all instances
;;        '2 -> this is the type name: Number. we're asking for n random numbers.
(syntax select-from-collection-by-random
	(lambda (node compiler)
	  (let ((input [node third]) (type [node fourth]) (quantity [node second]))
	    `(let ()
	       (if [',type = '2]
		   [john-max-int random: ,quantity] ;; fixme
		   (let ((collection (if ,type (filter-object-list ,input ,0) ,input)))
		     [collection random: ,quantity]))))))

(syntax quantify-clause
 	(lambda (node compiler)
	  `(let ((quantifier ,[node second]) ;;'1 -> every ; '2 -> any
		 (collection ,[node third])
		 (isAll [quantifier = '0]) (isEvery [quantifier = '1]) (isAny [quantifier = '2]))
	     (let ((flag (if isEvery john-false john-true)) (init [flag not]))
	       (let ((i '0))
		 (while [i < [collection size]]
			(let ((retVal (let ((,[node fifth] [collection at: i])) ,[node fourth])))
			  (if (== retVal flag)
			      (let () (set init flag) (break))))
			(set i [i + '1]))
		 init)))))

(syntax for-loop
 	(lambda (node compiler)
	  `(let ((i '0) (collection ,[node third]))
		 (while [i < [collection size]]
			(let ((,[node fifth] [collection at: i])
			      (Index i))
			  ,[node fourth])
			(set i [i + '1]))
		 john-ok)))

;; two kinds of qualifications: with and without args.
;; case 1: qualify <type> <name> <body>
;; case 2: qualify <type> <msg1>:<var1> <msg2>:<var2> ... <body>
(syntax qualify-type-or-class
	(lambda (node compiler)
	  (let ((type [node second]) (name [node third]) 
		(value [node fourth]) (pred [node fifth]) (vars [node at: '5])
		(body (if pred `(if ,pred ,value john-nil) value))
		(mw [johnCurrently currentMicroWorld])
		(classes [mw classes])
		(qualificationIndex 
		 (if [[mw typeQualifications] includesKey: type]
		     (if [[[mw typeQualifications] at: type] includesKey: name]
			 [[[[mw typeQualifications] at: type] at: name] + '1]
			 '0)
		     (let ()
		       [[mw typeQualifications] at: type 
			put: [IdentityDictionary new]]
		       '0)))
		;; we may have multi-definitions for a single method (qualification)
		;; so we internally save these methods with an index starting from 0
		;; eg, cdr0, cdr1, etc.
		;; when qualification cdr is called the method cdr will envoke all cdr"i"s
		;; until one has a non false boolean value...  
		(nameIntern [[name , '_] , qualificationIndex])
		(typeQualsDic [[mw typeQualifications] at: type])
		(qualVarNames (if vars [vars applyMsgsAndMap: [Array with: 'second]] 0))
		(internMethodDef 
		 (if vars 
		     `(define-send ',nameIntern ,type ,@qualVarNames ,body)
		     `(let ()
			(define-send ',nameIntern ,type ,body)
			;; also define this msg for collections if the type
			;; itself isnt a collection:
			(if (not (or [',type = 'List] [',type = 'Set] 
				     [List understands: ',name]))
			    (let ()
			      (define-send ',name List [self mapMsg: ',name])
			      (define-send ',name Set [self mapMsg: ',name]))))))
		(mainPartDef
		 `(let ((numOfQuals [',typeQualsDic at: ',name]) (i '0))
		    (while (and [i <= numOfQuals] (not res))
			   (let ((nameIntern2 [[',name , '_] , i]))
			     (set res (send nameIntern2 self))
			     (set i [i + '1])))))
		(mainWholePartDef
		 ;; do caching for defined types, not primitive ones
		 (if [[johnKB getClass: type] isMicroWorldClass]
		     `(let ((wm johnCurrently) (currWorld [wm currentWorld]) (res 0)
			    (cacheLookup [wm get: self property: ',name exactWorld: currWorld]))
			;; check if the qualification value is cached in this world
			(if [cacheLookup at: '0]
			    [cacheLookup at: '1]
			    (let ()
			      ,mainPartDef
			      ;; cache it:
			      [currWorld cache: self property: ',name value: res]
			      res)))
		     `(let ((res 0)) ,mainPartDef res)))
		(mainMethodDef 
		 (if vars
		     `(define-send ',name ,type ,@qualVarNames
			(let ((numOfQuals [',typeQualsDic at: ',name]) 
			      (i '0) (res 0))
			  (while (and [i <= numOfQuals] (not res))
				 (let ((nameIntern2 [[',name , '_] , i]))
				   (set res (send nameIntern2 self ,@qualVarNames))
				   (set i [i + '1])))
			  res))
		     `(define-send ',name ,type ,mainWholePartDef))))
	    [typeQualsDic at: name put: qualificationIndex]
	    `(let () 
	       ,internMethodDef
	       ;; if this qualification is new then we need to define main qual method
	       ;; the main method keeps invoking internal indexed ones until one returns
	       ;; none false value
	       (if [',qualificationIndex = '0] ,mainMethodDef)
	       john-ok))))

(syntax start-world
	(lambda (node compiler)
	     `[johnKB addMicroWorld: ',[node second]]))

(syntax cont-world
	(lambda (node compiler)
	  `(let ((theMicroWorld [[johnKB microWorlds] at: ',[node second]]))
	     [johnCurrently currentMicroWorld: theMicroWorld]
	     john-ok)))

;; defines this microworld class as a real cola class:
;; also defines how its objects are constructed, how their properties are stored, and looked up...
(syntax create-class
	(lambda (node compiler)
	  (let ((name [node second])
		(propertyTypes [[node third] applyMsgsAndMap: [Array with: 'first]])
		(propertyNames [[node third] applyMsgsAndMap: [Array with: 'second]])
		(newMicroWorldClass [MicroWorldClass new])
		(mw [johnCurrently currentMicroWorld])
		(parentClass (if [[[mw groups] at: 'classes] includesKey: name]
				 ;; for now single p
				 [[[[[mw groups] at: 'classes] at: name] keys] first]
				 'MicroWorldObject))
		;; stores each propertyname/value pair for the object
		(storeAndLookupDef
		 (let ((e1 `(let () 0)) (e2 `(let () 0)) (i '0)) 
		   (while [i < [propertyNames size]]
			  ;; the following hack fixme marks the circular
			  ;; dependency hash with the correct referenced
			  ;; but yet undefined obj, so that when it is 
			  ;; defined, this obj property is updated to point
			  ;; to it:
			  (set e1 [Expression 
				   withAll: e1
				   with: `(let ((propVal ,[propertyNames at: i])) 
					    ;; add property as new var for solverInfo
					    [[solverInfo at: 'vars] 
					     at: [[theName , '.] , ',[propertyNames at: i]] 
					     put: [Array with: newObjVar
							 with: ',[propertyNames at: i]
							 with: ',[[propertyTypes at: i] second]]]
					    [[solverInfo at: 'varTypes] 
					     at: ',[[propertyTypes at: i] first] 
					     put: ',[[propertyTypes at: i] second]]
					    ;; hack fixme: checking if this property
					    ;; is referencing a yet undef obj:
					    ;; (if the property value is a capitalized
					    ;; symbol it must be an object name. and
					    ;; if its not in the list of all objects
					    ;; then it must be not defined yet:
					    (if (and [propVal isSymbol] 
						     [propVal isCapitalized]
						     (not [[[johnCurrently currentMicroWorld] instances] includesKey: propVal])) 
						(if [circularObjDefs includesKey: propVal]
						    [[circularObjDefs at: propVal] at: theName put: ',[propertyNames at: i]]
						    [circularObjDefs at: propVal 
								     put: (let ((newDic [IdentityDictionary new])) 
									    
									    [newDic at: theName put: ',[propertyNames at: i]]
									    newDic)])
						
						[propNameToValDict at: ',[propertyNames at: i] 
								   put: propVal]))])
			  (set e2 [Expression
				   withAll: e2
				   with: `(let ()
					    (define-send ',[propertyNames at: i] ,name time
					      [johnCurrently get: self
					       property: ',[propertyNames at: i]
					       time: time])
					    ;; also define property lookup for collection of objs
					    (define-send ',[propertyNames at: i] List time
					      [self mapMsg: ',[propertyNames at: i] 
						    withArguments: [OrderedCollection with: time]])
					    (define-send ',[propertyNames at: i] Set time
					      [self mapMsg: ',[propertyNames at: i] 
						    withArguments: [OrderedCollection with: time]])
					    ;; define prop var lookup for solver
					    (define-send ',['compiled_ , [propertyNames at: i]] ,name
					      (let ((key [[[self name] , '.] , ',[propertyNames at: i]]))
						(if [[solverInfo at: 'oopta] includesKey: key]
						    [[solverInfo at: 'oopta] at: key]
						    (send ',[propertyNames at: i] self))))
					    ;; mark it as also a compiled msg send for solver
					    [[solverInfo at: 'compiled-msg-sends]
					     at: ',[propertyNames at: i]  put: '1]
					    )
				   ])
			  (set i [i + '1]))
		   [Array with: e1 with: e2]))
		(storeDef [storeAndLookupDef at: '0]) 
		(lookupDef [storeAndLookupDef at: '1]))
	    `(begin 
	       ;; defining the class:
	       (define-type ,name ,parentClass ( name ))
	       (define-send 'group ,name ,parentClass)
	       ;; defining the constructor for the class:
	       (define-send 'withNameAndProperties: ,name theName ,@propertyNames
		 (let ((newObjVar [self new]) (i '0) 
		       (propNameToValDict [IdentityDictionary new])
		       (wm johnCurrently)
		       (instPropNameValDict 
			[[wm currentWorld] 
			 instancePropertyValues]))
		   [newObjVar class: ',newMicroWorldClass]
		   [[[newObjVar class] instances] at: theName put: newObjVar]
		   [[[wm currentMicroWorld] instances] at: theName put: newObjVar]
		   [newObjVar name: theName]
		   ,storeDef
		   [instPropNameValDict at: theName put: propNameToValDict]
		   newObjVar))
	       ;; (define-send <prop name> <class name> [ lookup in the current world... ])
	       ,lookupDef			   
	       ;; instantiate a new MicroWorldClass for this micro world
	       [',newMicroWorldClass name: ,name]
	       [',newMicroWorldClass microWorld: ',mw]
	       [',newMicroWorldClass propertyNames: ',propertyNames]
	       [',newMicroWorldClass actions: [IdentityDictionary new]]
	       [',newMicroWorldClass goals: [IdentityDictionary new]]
	       [',newMicroWorldClass instances: [IdentityDictionary new]]
	       [[',mw classes] at: ',name put: ',newMicroWorldClass]
	       john-ok))))

;; grouping of classes (super class)
(syntax create-group
	(lambda (node compiler)
	  (let ((groupName [node second]) (memberClasses [node third])
		(mw [johnCurrently currentMicroWorld])
		(newMicroWorldClassGroup [MicroWorldClassGroup new])
	        (grpsDic [[mw groups] at: 'groups])
		(classesDic [[mw groups] at: 'classes]))
	  `(begin
	     [',newMicroWorldClassGroup name: ',groupName]
	     [',newMicroWorldClassGroup members: [IdentityDictionary new]]
	     [',memberClasses 
	       doFn: (lambda (className args) 
		       (let ()
			 (if (not [[args at: '0] includesKey: className])
			     [[args at: '0] at: className put: [IdentityDictionary new]])
			 [[[args at: '0] at: className] at: [args at: '1] put: [args at: '2]]))
	       args: [Array with: ',classesDic with: ',groupName with: ',newMicroWorldClassGroup]]
	     [',grpsDic at: ',groupName put: ',newMicroWorldClassGroup]
	     (define-type ,groupName MicroWorldClassGroup ( name members ))
	     john-ok))))

;; adds a new instance of a class
(syntax make-object
	(lambda (node compiler)
	  (let ()
	    ;; the hack fixme below is for circular dependency property defs
	    ;; if any of the properties of this new object is going to be
	    ;; another object that's not yet defined, we need to flag this
	    ;; and later when that is defined fix this obj property:
	    [[node fourth] doFn: 
	     (lambda (elm args) 
	       ;; only do this for properties that are undefined object names
	       ;; for now just define them with value of their name (until they're
	       ;; really instanciated.
	       (if (and [elm isSymbol] 
			[elm isCapitalized]
			(not [TheGlobalEnvironment lookupVariable: elm]))
		   [TheGlobalEnvironment defineVariable: elm value_: elm]))
	     args: 0]
	    `(let ((newObj (send 'withNameAndProperties: ,[node second] ,[node third] ,@[node fourth])))
	       ;; define variable pointing to the new object:
	       [TheGlobalEnvironment defineVariable: ,[node third] value_: newObj]
	       ;; the following for circular obj defs. check if any objs have this
	       ;; new obj in their properties, in such case we need to fix their 
	       ;; property value now:
	       (if [circularObjDefs includesKey: ,[node third]]
		   (let ((objs [circularObjDefs at: ,[node third]]))
		     ;; now that the obj is defined, go and fix property
		     ;; values of those other objs who has this one
		     ;; as a property:
		     [[objs keys] 
		      doFn: (lambda (elm args)
			      [[args at: '0]
			       update: elm
			       property: [[args at: '2] at: elm]
			       value: [args at: '1]])
		      args: [Array with: [johnCurrently currentWorld] 
				   with: newObj with: objs]]
		     ;; now circular def is resolved remove from list:
		     [circularObjDefs removeKey: ,[node third] ifAbsent: 0]
		     ))
	       [[solverInfo at: 'objects] add: ,[node third]]
	       john-ok))))

;; defines how actions are run (method call)
;; also set that if this action takes arguments and user is calling it without them
;; it means use search to decide the action parameters.
(define action-run-def
  (lambda (actionCause consequence)
    `(let ((wm johnCurrently) (doCachingKeep [wm doCaching]))
       ;; need to turn off qualification caching while doing action, 
       ;; since we've already moved into the child world
       [wm doCaching: john-false]
       [wm advanceTime: (make-collection List ,@actionCause)]
       ,consequence 
       [wm doCaching: doCachingKeep]
       john-ok)))

;; isForAction is an arg to tell the goal run that we just want to find the next action towards the goal
;; (and not solve the entire path to goal): used for automatic action runs (action called w/o args)
;; byActors if given limits actors of actions that generate possible worlds, similarly usingActions
(define goal-run-def
  (lambda (goalPred goal)	
    `(let ()
       (if ,goalPred
	   (return john-msg-already-satisfied)
	   ;; an infinte loop so if searched timed out and we use heuristics to prune
	   ;; the tree, we come back here and continue the seach.
	   ;; adjustTime gets incremented to allow to go deeper in the search tree
	   ;; as we prune the tree using heuristics.
	   (let ((adjustTime '0) (maxTimeAhead [john-opts at: 'max-time-ahead])
		 (wm johnCurrently) (origCurrWorld [wm currentWorld])
		 (mw [wm currentMicroWorld]) (isTwoPlayerGame [john-opts at: 'two-player-game])
		 (possibleActionRuns 0) (oppPossibleActionRuns 0)
		 (hasOpt 
		  (or [',goal hasSatOptimizations]
		      (and usingActions 
			   (let ((optimizationOpt [[usingActions at: '0] hasSatOptimizations]))
			     (and optimizationOpt [optimizationOpt at: '0]))))))

	     ;; if goal has optimizations, we cannot determine actions statically.
	     ;; also only if actions dont have dynamic optimizations (either no optimizations, or
	     ;; static ones) we can determine all possible parameter
	     ;; combinations statically. if not, it cannot be done now...
	     (if (not hasOpt)
		 (let ()
		   (set possibleActionRuns 
			[mw getPossibleActionRunsBy: byActors using: usingActions])
		   (set oppPossibleActionRuns 
			(if isTwoPlayerGame
			    (let ((oppActors [OrderedCollection with: [twoPlayerGameOpps at: [self name]]]))
			      [mw getPossibleActionRunsBy: oppActors using: usingActions])
			    0))))
	     ;; if this is for an action, only search based on that object and action
	     (while 1
		    (let ((timeAhead '1) (possibleWorlds [OrderedCollection new]))
		      (while [[timeAhead - [adjustTime * maxTimeAhead]] <= maxTimeAhead]
			     (let ()
			       [john-msg-looking_1 put] 
			       [[timeAhead + adjustTime] print] 
			       [john-msg-looking_2 put]
			       (set possibleWorlds 
				    [wm getPossibleWorldsIn: timeAhead 
					byPossibleActionRuns: possibleActionRuns 
					isTwoPlayerGame: isTwoPlayerGame 
					byOpponentPossibleActionRuns: oppPossibleActionRuns
					isForGoal: ',goal isForAction: usingActions andObj: self
					hasOpt: hasOpt])
			       (let ((numPossWorlds [possibleWorlds size]) 
				     (i '0))
				 [numPossWorlds print] 
				 [john-msg-looking_3 putln]
				 (if [numPossWorlds = '0]
				     (if isForAction
					 (break)
					 (let ()
					   [wm currentWorld: origCurrWorld]
					   (return john-msg-not-satisfiable))))
				 (if (and isForAction [numPossWorlds = '1]
					  [[timeAhead + adjustTime] = '1])
				     (let ()
				       [wm currentWorld: [possibleWorlds at: '0]]
				       ;; for 2-player-games, better clear possible worlds
				       ;; cache since the game tree is different based on
				       ;; whose turn it is...
				       (if isTwoPlayerGame
					   [[wm currentWorld] children: [IdentityDictionary new]])
				       (return john-ok)))
				 (while [i < numPossWorlds]
					(if (and (not isForAction)
						 (eval-in-world ,goalPred 
								[possibleWorlds at: i]))
					    (let ((goalWorld [possibleWorlds at: i])
						  (pathToGoal [goalWorld getPathFromWorld: origCurrWorld]))
					      [wm currentWorld: goalWorld]
					      [john-msg-satisfied_1 put]
					      [[[possibleWorlds at: i] time] println]
					      [john-msg-satisfied_2 put]
					      [pathToGoal printlnMe]
					      (return john-ok)))
					(set i [i + '1]))))
			     (set timeAhead [timeAhead + '1]))
		      ;; we are too deep in the search tree, 
		      ;; use any heuristics to pick a world from seen possible worlds instead
		      [john-msg-timeout putln]
		      (if [[possibleWorlds size] = '0]
			  (let ()
			    [wm currentWorld: origCurrWorld]
			    (return john-msg-not-satisfiable))
			  (let ((currWorld [wm currentWorld])
				(pickedWorlds (send 'pickFromPossibleWorldsByHeuristics self ',goal possibleWorlds))
				;; pick randomlu among maybe multiple highest scoring ones:
				(pickedWorld [pickedWorlds randomOne]))
			    ;; we have picked one of the possible worlds as the best rout
			    ;; prune the rest of tree (all branches this pw not part of)
			    ;; by setting the current world its ancestor world at time
			    ;; current time + 1
			    (let ((pickedNextWorld [pickedWorld getParentAtTime: [[currWorld time] + '1]]))
			      [[String lf] put]
			      [wm currentWorld: pickedNextWorld]
			      ;; if we're just finding next action we're done
			      (if isForAction (let ()
						(if isTwoPlayerGame
						    [pickedNextWorld children: [IdentityDictionary new]])
						(return john-ok)))
			      [currWorld pruneChildrenTo: pickedNextWorld] 
			      (set adjustTime [adjustTime + '1]))))
		      ))))
       john-ok)))

;; defines an action (method) or a goal for a class
(syntax action-or-goal-def 
	(lambda (node compiler)	
	  (let ((isAction [[node at: '5] = '1]) ;; fixme
		(actionVarClassesAndNames [node fourth])
		(actionVarClasses [actionVarClassesAndNames applyMsgsAndMap: [Array with: 'first]])
		(actionVarNames [actionVarClassesAndNames applyMsgsAndMap: [Array with: 'second]])
		(className [node second]) (class [johnKB getClass: className]) 
		(name [node third]) (newClassActionOrGoal (if isAction [Action new] [Goal new]))
		(classActionsOrGoals (if isAction [class actions] [class goals]))
		(actionCause [OrderedCollection with: 'self with: `',name withAll: actionVarNames])
		(mainBody (if isAction
			      (action-run-def actionCause [node fifth])
			      (goal-run-def [node fifth] newClassActionOrGoal)))
		;; fixme: this hack so actions run search when called w/o args:
		;; b/c jolt repeats expr elms when some missing...
		(argCheckCode `(let ((goalList [[[self class] goals] keys]))
				 (if [[goalList size] = '0]
				     john-nil
				     ;; fixme: only tries one goal of a class
				     (send [goalList at: '0] self 
					   [OrderedCollection with: self]
					   [OrderedCollection with: ',newClassActionOrGoal]
					   1
					   ,@actionVarNames))))
		(body (if (and isAction [[actionVarNames size] ~= '0])
			  `(if ,[actionVarNames at: '0]
			       ,mainBody
			       ,argCheckCode)
			  mainBody))
		(goalSolveNoOptBody
		 `(let ()
		    (reset-solver-info)
		    (compile-to-solver-source self ',['compiled_goal_ , name])
		    (if [solverInfo at: 'outcome] john-ok john-false)))
		(goalSolveBody 
		 `(let ()
		    (if ,[node fifth]      
			john-msg-already-satisfied
			;; run any goal optimizations to do assignments as partial solutions...
			(let ((hasOpt [',newClassActionOrGoal hasOptimizations])
			      (preOptCurrWorld [johnCurrently currentWorld]))
			  (if hasOpt (send 'runAssignmentsByGoalOptimizations self))
			  (if (or ,[node fifth]
				  ,goalSolveNoOptBody 
				  (and hasOpt 
				       (let () [johnCurrently currentWorld: preOptCurrWorld] 
					    ,goalSolveNoOptBody))) john-ok john-no)))))
		(def (if isAction
			 `(let () 
			    (define-send ',name ,className ,@actionVarNames ,body)
			    ;; also define a version that does not check rules (for upon clause)
			    (define-send ',[name , '-no-rule-check] ,className ,@actionVarNames ,body))
			 `(let () 
			    ;; this one uses john's planner:
			    (define-send ',[name , '-sat] ,className byActors usingActions isForAction ,@actionVarNames ,body)
			    ;; this one uses external solver:
			    (define-send ',[name , '-solve] ,className ,goalSolveBody)))))
	    `(let ()
	       ;; defines action (procedure) / goal (meanining): 
	       ,def
	       [',newClassActionOrGoal name: ',name]
	       [',newClassActionOrGoal class: ',class]
	       [',newClassActionOrGoal variableClasses: ',actionVarClasses]
	       [',newClassActionOrGoal variableNames: ',actionVarNames]
	       (if ',isAction
		   (let ()
		     [',newClassActionOrGoal argCheckExpr: ',argCheckCode]
		     [',newClassActionOrGoal consequence: ',mainBody]
		     [',newClassActionOrGoal rules: john-nil])
		   (let ()
		     [',newClassActionOrGoal heuristics: [OrderedCollection new]]
		     [',newClassActionOrGoal allHeuristicsExpr: `(let ())]
		     [',newClassActionOrGoal allOptimizationsExpr: `(let ())]
		     [',newClassActionOrGoal allSatOptimizationsExpr: `(let ())]))
	       [',classActionsOrGoals at: ',name put: ',newClassActionOrGoal]
	       john-ok))))

;; adds a rule for an action
(syntax action-rule
	(lambda (node compiler)	
	  (let ((className [node second]) (actionName [node third]) 
		(rulePred [node fourth]) (class [johnKB getClass: className])
		(action [[class actions] at: actionName]) (actionVarNames [action variableNames])
		(rulesSofar (if [action rules] `(and ,[action rules] ,rulePred) rulePred))
		(mainBody `(if ,rulesSofar ,[action consequence] john-nil))
		(body (if [[actionVarNames size] ~= '0]
			  `(if ,[actionVarNames at: '0]
			       ,mainBody
			       ,[action argCheckExpr])
			  mainBody)))
	    `(let ()
	       (define-send ',actionName ,className ,@actionVarNames ,body)
	       [',action rules: ',rulesSofar]
	       john-ok))))

;; adds a heuristic for a goal
;; defines for objects how to:
;; given a list of possible worlds, based on any defined heuristics for a goal picks the best
;; world (tree pruning). if no heuristics defined, picks one by random
;; hack fixme: didnt know how to generate code that tries each heuristic 
;; separately (need to unquote each heuristic's expression)
;; so here we're repeating the same piece of code for each heuristic!
(syntax goal-heuristic
	(lambda (node compiler)	
	  (let ((className [node second]) (class [johnKB getClass: className]) 
		(goal [[class goals] at: [node third]]) 
		(theHeuristicType [node fifth]) (theHeuristicExpr [node at: '5])
		(repeatedPart 
		 `(let ((i '0) (scoresSum '0) (tempScores [IdentityDictionary new]) (j '0) (k '0) 
			(theHeuristicWeight ',[node fourth])
			(isMinimize (== ',theHeuristicType john-minimize))
			(isMaximize (== ',theHeuristicType john-maximize))
			(isEstablish (== ',theHeuristicType john-establish)))

		    ;; duplicated the code for isEstablish / normal cases to take the if cond
		    ;; out of the loop for efficiency purposes...
		    (if isEstablish

			(while [i < [possibleWorlds size]]
			       (let ((preRawPWScore (eval-in-world ,theHeuristicExpr
								   [possibleWorlds at: i]))
				     ;; in the 'establish' case we use '1 for true
				     ;; and value '0 for false:
				     (rawPWScore (if preRawPWScore '1 '0)))
				 [tempScores at: i put: rawPWScore]
				 (set scoresSum [scoresSum + rawPWScore]))
			       (set i [i + '1]))

			(while [i < [possibleWorlds size]]
			       (let ((rawPWScore (eval-in-world ,theHeuristicExpr
								   [possibleWorlds at: i])))
				 [tempScores at: i put: rawPWScore]
				 (set scoresSum [scoresSum + rawPWScore]))
			       (set i [i + '1])))

		    ;; scores are negated if is a minimize type heuristic, also done in its
		    ;; own loop to take the if statement out of loop for efficiency...
		    (if isMinimize
			(while [k < [possibleWorlds size]]
			       [tempScores at: k put: [[tempScores at: k] * '-1]]
			       (set k [k + '1])))

		    ;; in order to make the weight of all heuristics the same 
		    ;; have to calc scores as fraction of heuristic expression
		    ;; value of the whole sum
		    (while [j < [possibleWorlds size]]
			   (let ((pwScore [tempScores at: j])
				 (pwScoreF [theHeuristicWeight * [pwScore / scoresSum]]))
				 [pwScores at: j put: [[pwScores at: j ifAbsentPut: '0] + pwScoreF]])
			   (set j [j + '1]))))
		
		(allHeuristicsEvalExpr [Expression withAll: [goal allHeuristicsExpr] 
						   with: repeatedPart])
		(body 
		 `(let ((heuristics [goal heuristics]))
		    (if (== [heuristics size] '0)
			;; no heuristics defined... random picking:
			[possibleWorlds randomOne]
			;; we have heuristics... pick the possible world best matching heuristics
			;; sum the score from all heuristics for each possible world and pick the
			;; world with the highest score sum (for minimize heuristics we negate)
			(let ((pickIndex '0) (pwScores [IdentityDictionary new]))
			  [john-msg-consulting put]
			  ,allHeuristicsEvalExpr
			  ;; now we have sumed up the score from all heuristics for each pw,
			  ;; return the highest scoring one (or ones):
			  [possibleWorlds atAll: [pwScores keysWithExtremum: 0]])))))
	    [goal allHeuristicsExpr: allHeuristicsEvalExpr]
	    `(let ((heuristic [GoalHeuristic new]))
	       [heuristic goal: ',goal]
	       [heuristic weight: ',[node fourth]]
	       [heuristic type: ',theHeuristicType]
	       [heuristic expression: ',theHeuristicExpr]
	       [[',goal heuristics] add: heuristic]
	       (define-send 'pickFromPossibleWorldsByHeuristics ,className 
		 goal possibleWorlds ,body)
	       john-ok))))

(syntax goal-optimization
	(lambda (node compiler)	
	  (let ((className [node second]) (class [johnKB getClass: className]) 
		(goal [[class goals] at: [node third]]) (optName [node fourth]) 
		(assignment [node fifth])
		(optimizationsProcessExpr [Expression withAll: [goal allOptimizationsExpr] 
						      with: assignment])
		(body `(let () ,optimizationsProcessExpr)))
	    [goal allOptimizationsExpr: optimizationsProcessExpr]
	    [goal hasOptimizations: 1]
	    `(let ()
	       ;; goal optimizations do pre-inference assignments as partial (or complete) models
	       ;; to be used by the solver
	       (define-send 'runAssignmentsByGoalOptimizations ,className ,body)
	       john-ok))))

(syntax goal-sat-optimization
	(lambda (node compiler)	
	  (let ((className [node second]) (class [johnKB getClass: className]) 
		(goal [[class goals] at: [node third]]) (actionName [node fourth])
		(repeatedPart `(if ,[node fifth] [actionList at: ',actionName put: '1]))
		(optimizationsProcessExpr [Expression withAll: [goal allSatOptimizationsExpr] 
						      with: repeatedPart])
		(body `(let ((actionList [IdentityDictionary new]))
			 ,optimizationsProcessExpr
			 ;; discard those possibleActionRuns whose action name (2nd elm) 			 ;; isnt in the actionList as determined by optimization
			 [[self class] getActions: [actionList keys]])))
	    [goal allSatOptimizationsExpr: optimizationsProcessExpr]
	    [goal hasSatOptimizations: 1]
	    `(let ()
	       ;; goes through candidate actions that can produce possible worlds, and
	       ;; filters them by evaling the preds in the defined optimizations
	       (define-send 'getPossibleActionsByGoalOptimizations ,className ,body)
	       john-ok))))

(syntax action-optimization
	(lambda (node compiler)	
	  (let ((className [node second]) (isEstablishType [node fifth])  
		(isDynamicType [node at: '5]) (class [johnKB getClass: className]) 
		(action [[class actions] at: [node third]])
		(body (if (and [action hasOptimizations] isEstablishType)
			  `(and ,[action allOptimizationsExpr] 
				,[node fourth])
			  `,[node fourth]))
		(methodName ['reducePossibleActionParamsByOptimizationsForAction- , [node third]]))
	    [action allOptimizationsExpr: body]
	    [action hasOptimizations: [OrderedCollection with: (if isDynamicType 1 0)
							 with: (if isEstablishType 0 1)]] 
	    `(let ()
	       ;; goes through candidate action paramters combinations and
	       ;; filters them by evaling the preds in the defined optimizations
	       (define-send ',methodName ,className
		 ,@[action variableNames] ,body)
	       john-ok))))

(syntax action-run
	(lambda (node compiler)
	  `(let ((ret (send ',[node third] ,[node second] ,@[node fourth])))
	     (check-auto-draw ret))))

(syntax goal-run
	(lambda (node compiler)
	  (let ((obj [node second]) (goalName [node third]) (goalParams [node fourth])
		(byActors [node fifth]) (usingActions [node at: '5]))
	    ;; go from object names to objects, and actions names to actions:
	    (if byActors (set byActors [johnKB getObjects: byActors]))
	    (set usingActions (if usingActions 
				  [[[johnKB getObject: obj] class] getActions: usingActions]
				  [[johnCurrently currentMicroWorld] allActions]))
	    `(let ((ret (send ',[goalName , '-sat] ,obj ',byActors ',usingActions 0 ,@goalParams)))
	       (check-auto-draw ret)))))

(syntax goal-solve
	(lambda (node compiler)
	  (let ((obj [node second]) (goalName [node third]) (goalParams [node fourth]) 
		(byActors [node fifth]) (usingActions [node at: '5]))
	    `(let ()
	       (send ',[goalName , '-solve] ,obj)))))

(syntax visual-def 
	(lambda (node compiler)	
	  (let ((className [node second]) (class [johnKB getClass: className]))
	    `(let ()
	       (define-send 'draw ,className ,[node third])
	       john-ok))))

(syntax make-drawing
	(lambda (node compiler)	
	  (let ((x [node second]) (y [node third]) (items [node fourth]) (exp `(let ()))
		(fn (lambda (elm exp na) 
		      [Expression withAll: exp 
				  with: `[,elm draw]])))
	    (if x (set exp [Expression withAll: exp with: `[[String lf] put: ',x]]))
	    (if y (set exp [Expression withAll: exp with: `[[String space] put: ',y]]))
	    (set exp [items accumulate: fn init: exp arg: 0])
	    `,exp)))

(syntax draw-items
	(lambda (node compiler)	
	  `(let () ,[node second] [[String lf] put] john-ok)))

(syntax explicit-assignment
	(lambda (node compiler)
	  `(let () 
	     [johnCurrently advanceTime: (make-collection List 0)]
	     ,[node second] 
	     john-ok)))

(syntax set-bounds
	(lambda (node compiler)
	  (let ((lower [node third]) (upper [node fourth]) (diff [[upper - lower] + '1])
		(list [List withAll: [lower to: upper]]))
		`(let () 
		   (define-send 'all ,[node second] ',list)
		   (if (< [[solverInfo at: 'bounds] at: 'Integer] ',diff)
		       [[solverInfo at: 'bounds] at: 'Integer put: ',diff])
		   john-ok))))

;; changes interpreter default settings
(syntax set-opt
	(lambda (node compiler)
	  `(let ()
	     ;; for two-player-game option, remember opponents...
	     (if [',[node second] = 'two-player-game]
		 (let ((one [,[node third] at: '0]) (two [,[node third] at: '1]))
		   [twoPlayerGameOpps at: [one name] put: two]
		   [twoPlayerGameOpps at: [two name] put: one]))
	     [john-opts at: ',[node second] put: ,[node third]] john-ok)))

(define translate-list-bounds 
  (lambda (size type)
    [Array with: ['u , size] with: ['u , [[solverInfo at: 'bounds] at: type]]]))

(define translate-oop-val-to-solver-val
  (lambda (val)
    (let ((res '"{") (i '0) (s [val size]) (oopta [solverInfo at: 'oopta]))
      (while [i < s]
	     (set res [res , [[[['"[" , ['A , i]] , '", "] , [oopta at: [val at: i]]] , '"]"]])
	     (set i [i + '1])
	     (if [i < s] (set res [res , '", "])))
      [res , '"}"])))

(define compile-to-solver-source
  (lambda (obj compiledGoalName)
    (let ((classes [[johnCurrently currentMicroWorld] classes]) (objName [obj name])
	  (oopta [solverInfo at: 'oopta]) (atoop [solverInfo at: 'atoop])
	  (unknowns [solverInfo at: 'unknowns])
	  (intB [[solverInfo at: 'bounds] at: 'Integer]) (i '0) (atomN '0) (relN '0) 
	  (varTypes [solverInfo at: 'varTypes]) (varTypesK [varTypes keys])
	  (intBStr '"int_bounds: [") (knownsBStr '"") (unknownsBStr '"") 
	  (functionsBStr '"solve ")
	  (asm [['"solver: \"" , [solverInfo at: 'solver]] , 
		'"\"\nsymmetry_breaking: 3\nflatten: false\n"]))      
      ;; figure out total universe atoms...
      (while [i < [varTypesK size]]
	     (let ((k [varTypesK at: i]) (fullTp [varTypes at: k]) (tpName [fullTp first]) 
		   (tp [classes at: [fullTp last]]))
	       (let ((range (send 'all tp)) (j '0))
		 ;; build int_bounds line...
		 (while [j < [range size]]
			(let ((atom ['A , atomN])) 
			  [oopta at: atomN put: atom] [atoop at: atom put: atomN])
			(set intBStr [intBStr , [['"{A" , [atomN asString]] , '"}"]])
			(set atomN [atomN + '1])
			(set j [j + '1])
			(if [atomN < intB] (set intBStr [intBStr , '", "]) 
			    (set intBStr [intBStr , '"]"])))))
	     (set i [i + '1]))
      ;; a. fix known vars bounds and b. specify unknown vars bounds 
      (let ((vars [solverInfo at: 'vars]) (ks [vars keys]) (kss [ks size]) (j '0))
	(while [j < kss]
	       (let ((varN [ks at: j]) (var [vars at: varN]) (fullTp [var third]) 
		     (tp [fullTp first]) (val (send [var second] [var first] 0)) (itm 0))
		 (if (== tp 'List) ;; fixme
		     (let () 
		       (set itm ['r , relN]) (set relN [relN + '1])
		       [oopta at: varN put: itm]
		       [atoop at: itm put: varN]
		       (if [val first]
			   ;; known var
			   (set knownsBStr 
			    [[[knownsBStr , [['"bounds " , itm] ,'": "]] , 
			      (translate-oop-val-to-solver-val val)] , '"\n"])
			   ;; unknown var
			   (let ((listB (translate-list-bounds [fullTp second] [fullTp third]))
				 (listDom [listB first]) (listRan [listB second]))
			     [unknowns at: itm put: [Array with: obj with: [var second]]]
			     (set functionsBStr [functionsBStr , 
				    [[[['"FUNCTION(" , itm] , '", "] , 
				      [[listDom , '"->one "] , listRan]] , '") &&\n"]])
			     (set unknownsBStr 
				  [[unknownsBStr , [['"bounds " , itm] , 
				   ['": [{}, " , [[listDom , '"->"] , listRan]]]] , '"]\n"]))))))
	       (set j [j + '1])))      
      [solverInfo at: 'universe put: atomN]      
      (set asm [asm , [['"bit_width: " , [[[[solverInfo at: 'bounds] at: 'Integer]
					   ceilLogn: '2] asString]] , '"\n"]])
      (set asm [asm , [['"univ: u" , [atomN asString]] , '"\n"]])
      (set asm [asm , knownsBStr])
      (set asm [asm , unknownsBStr])
      (set asm [[asm , intBStr] , '"\n"])
      (set asm [asm , functionsBStr])
      (set asm [[asm , (send compiledGoalName obj)] , '";\n"])
      [solverInfo println]
      [asm putln]
      (let ((asmFileN [['"/tmp/John." , [objName , ['. , compiledGoalName]]] , '".kki"])
	    (solverOutFileN [asmFileN , '".out"]) (asmFileH [File create: asmFileN])
	    (solverOutFileH [File create: solverOutFileN]))
	[asmFileH nextPutAll: asm]
	[asmFileH close]
	[solverOutFileH nextPutAll: '"{solver-output}\n"]
	[solverOutFileH close]
	[OS system: [[[solverInfo at: 'solver-cmd-line] , asmFileN] , 
		     ['" >> " , solverOutFileN]]]
	['"solver results " put]
	(load [solverOutFileN _stringValue])
	))))

;;;;;;;;;;;;;;;;;;;; compiled stuff ... ;;;;;;;;;;;;;;;;;;;;;;;;


(syntax collection-size-compiled
	(lambda (node compiler)
	  `[['"#(" , [,[node second] toString]] , '")"]))

(syntax collection-count-compiled
	(lambda (node compiler)
	  `[[[['"#(" , [,[node third] toString]] , '"."] , ,[node second]] , '")"]))

(syntax collection-indexing-compiled
	(lambda (node compiler)
	  `[[(make-string-w-parens ,[node third]) , '"."] , [,[node second] toString]]))

(syntax collection-indices-compiled
	(lambda (node compiler)
	  `['u , [[,[node second] compiledList] size]]))

(syntax collection-lastIndex-compiled
	(lambda (node compiler)
	  `['"u1@" , [[[[,[node second] compiledList] size] - '1] asString]]))	  

(syntax quantify-clause-compiled
 	(lambda (node compiler)
	  `(let ((quantifier ,[node second]) ;;'1 -> every ; '2 -> any
		 (isAll [quantifier = '0]) (isEvery [quantifier = '1]) (isAny [quantifier = '2])
		 (setNum [solverInfo at: 'setNum]))
	     (let ((,[node fifth] ['S , setNum]))
	       [solverInfo at: 'setNum put: [setNum + '1]]
	       [[[[[[[[[john-parens first] , 'all] , [String space]] , [john-brackets first]] ,
		    [[[,[node fifth] , john-colons] , [[String space] , ['one , [String space]]]] , 
		     [,[node third] toString]]] ,
		   [john-brackets second]] , [[String space] , [john-pipes , [String space]]]] ,
		 ,[node fourth]] , [john-parens second]]))))

(syntax send-compiled
        (lambda (node compiler)
	  `(let ((origSlctr ,[node second])
		 (slctr (if [[solverInfo at: 'compiled-msg-sends] includesKey: origSlctr]
			    ['compiled_ , origSlctr]
			    origSlctr)))
	     (send slctr ,[node third] ,[node fourth]))))

(syntax filter-object-list-compiled
	(lambda (node compiler)
	  `(let ((collection (filter-object-list ,[node second] ,[node third])))
	     [collection compiled])))

;; this is to enable dynamic dispatch via name (not value)
;; e.g. List sorted <--- 'r0 sorted  (if #r0 is compiled var name for a list)
(syntax extra-qualify-for-symbol-compiled 
        (lambda (node compiler)
	  (let ((sendArgs (if [node fifth] [[node fifth] applyMsgsAndMap: [Array with: 'second]] '())))
	    `(if [',[node second] ~= 'Symbol] 
		 (let ()
		   (if (not [Symbol understands: ',['compiled_ , [node third]]]) 
		       (define-send ',['compiled_ , [node third]] Symbol ,@sendArgs
			 (if [[solverInfo at: 'atoop] includesKey: self]
			     (send [['compiled_ , [[[[[solverInfo at: 'vars] at: [[solverInfo at: 'atoop] at: self]] third] first] , '_]] , ',[node third]] self ,@sendArgs)
			     john-error)))
		   (qualify-type-or-class Symbol ,[[['compiled_ , [node second]] , '_] , [node third]] ,[[node fourth] at: '0] ,[[node fourth] at: '1] ,[node fifth]))))))

(define [List compiled]
  'u21)

(define [Symbol compiledList]
  (let ((var [[solverInfo at: 'vars] at: [[solverInfo at: 'atoop] at: self]]))
    (send [var second] [var first] 0)))

(define make-string-2
	(lambda (x y)
	  [[[x toString] , '" "] , [y toString]]))

(define make-string-3
	(lambda (x y z)
	  (make-string-2 (make-string-2 x y) z)))

(define make-string-w-parens
  (lambda (x)
    (make-string-3 '"(" x '")")))

(define make-string-w-brackets
  (lambda (x)
    (make-string-3 '"[" x '"]")))

(define make-string-2-w-dot
	(lambda (x y)
	  (make-string-2 (make-string-2 x '".") y)))

(define make-string-2-w-parens
	(lambda (x y)
	  (make-string-3 '"(" (make-string-2 x y) '")")))
	    
(define make-string-3-w-parens
	(lambda (x y z)
	  (make-string-3 '"(" (make-string-3 x y z) '")")))

(define reset-solver-info
  (lambda ()
    [solverInfo at: 'unknowns put: [IdentityDictionary new]]
    [solverInfo at: 'setNum put: '0]))

;; this grammar to parse john programs...

['{

error		   = <- [self error: '"syntax error"]
eol		   = '\r' '\n'* | '\n' '\r'*
nonSpace	   = !(space | dot | rparen | rbrackets | rbraces | colon | comma)
endword		   = !nonSpace spaces
comment		   = ';' (!eol .)* eol | '/;' (!';/' .)* ';/'
space		   = [ \t] | eol | comment
spaces		   = space*
dot		   = '.'
char		   = ( . ->0 )		
		          <- [self @ '0]
end	           = !.
theEnd	           = 'end-world' spaces dot* | end

lparen		   = '(' spaces
rparen		   = ')' spaces
lbraces		   = '{' spaces
rbraces		   = '}' spaces
lbrackets	   = '[' spaces
rbrackets	   = ']' spaces
equals		   = '=' spaces
assign		   = ':=' spaces
colon		   = ':' spaces
comma		   = ',' spaces
pound		   = '#' spaces

keywords	   = 'Integer' | 'Word' | 'Sentence' | 'List' | 'Set' | 'yes' | 'no'
		   | 'not' | 'and' | 'or' | 'is' | 'if' | 'in' | 'at' | 'from' | 'to' | 'of'
		   | 'its' | 'it' | 'which' | 'one' | 'the' | 'a' | 'an' | 'all' 
		   | 'do' | 'for' | 'random' | 'select' 
		   | 'consequence'  | 'use' | 'by' | 'upon' | 'using' | 'satisfy' | 'solve'
		   | 'minimize' | 'maximize' | 'establish' | 'statically' | 'dynamically'
		   | 'time'  | 'qualify' | 'action' | 'rule' |  'heuristic' 
		   | 'goal-optimization' | 'goal-sat-optimization' | 'action-optimization' 
                   | 'visual' | 'draw' | 'set-opt' | 'world' | 'end-world'
keyword		   = keywords (space | dot | rparen)
at		   = 'at' endword
from		   = 'from' endword
to		   = 'to' endword
of		   = 'of' endword
time		   = 'time' endword
world              = 'world' endword
xcoord		   = ('x'|'X') endword
ycoord		   = ('y'|'Y') endword
it		   = ('its'|'it') endword <- john-it
which		   = 'which' endword <- john-which
pronoun            = it | which 
article		   = ('one' spaces 'from'|'the'|'a'|'an') endword
is		   = ('is'|'if') endword
in		   = 'in' endword
not		   = 'not' endword
all		   = 'all' endword
every		   = 'all' endword <- '1
any		   = 'any' endword <- '2
by		   = 'by' endword
using		   = 'using' endword
upon		   = 'upon' endword
for		   = 'for' endword
do	           = 'do' endword
suchThat	   = '|' endword
satisfy		   = 'satisfy' endword
solve		   = 'solve' endword
select		   = 'select' endword
random		   = 'random' endword
consequence	   = 'consequence' endword
use	   	   = 'use' endword
rule	   	   = 'rule' endword
minimize	   = 'minimize' spaces <- john-minimize
maximize	   = 'maximize' spaces <- john-maximize
establish	   = 'establish' spaces <- john-establish
statically         = 'statically' spaces <- 0
dynamically        = 'dynamically' spaces <- 1
exprHeuristicType  = minimize | maximize
staticDynamicType  = statically | dynamically
predHeuristicType  = establish
draw		   = 'draw' endword
booleanKeyword     = 'Boolean' endword
		          <- 'Boolean
numberKeyword      = 'Integer' endword
		          <- 'Integer
wordKeyword        = 'Word' endword
		          <- 'Symbol
sentenceKeyword    = 'Sentence' endword
		          <- 'String
listKeyword        = 'List' endword
		          <- 'List
setKeyword         = 'Set' endword
		          <- 'Set
type		   = (booleanKeyword | numberKeyword | wordKeyword | 
                      listKeyword | setKeyword | sentenceKeyword)->0 
		          <- [self @ '0]
fullType           = type
                          <- [Array with: result with: [Array with: result]]
                   | number->0 type->1 'List' endword
		          <- (let ()
                                (if (< [[solverInfo at: 'bounds] at: 'Integer] [self @ '0])
                                    [[solverInfo at: 'bounds] at: 'Integer put: [self @ '0]])
                                [Array with: [['List , [self @ '0]] , [self @ '1]]
                                       with: [Array with: 'List with: [self @ '0] with: [self @ '1]]])
true	     	   = 'yes' endword
		     	  <- john-true
false	     	   = 'no' endword
		     	  <- john-false
boolean 	   = true | false
mathAddOp          = spaces ('+' | '-') $->0 spaces
		     	  <- [[self @ '0] asSymbol]
mathMultOp         = spaces ('**' | '*' | '/' | '%') $->0 spaces
		     	  <- [[self @ '0] asSymbol]
mathCompOp	   = spaces ('=' | '<=' | '>=' | '<' | '>') $->0 spaces
		      	  <- [[self @ '0] asSymbol]
logicAndOp         = spaces 'and' $->0 endword
		     	  <- [[self @ '0] asSymbol]
logicOrOp          = spaces 'or' $->0 endword
		     	  <- [[self @ '0] asSymbol]
logicOp		   = logicAndOp | logicOrOp
logicOpCompiled	   = logicAndOp 
                          <- '" &&\n" 
                   | logicOrOp 
                          <- '" ||\n"
magnitude	   = ([0-9]+) $->0 spaces				
		          <- [Integer fromString: [self @ '0]]
number	           = '-' magnitude 				
		          <- [result negated]
		   | magnitude
		          <- result
string	 	   = '"' ( !'"' char )* ->0 '"' spaces		
		          <- [[self @ '0] asString]
stringExp	   = string
		          <- `',result
variableName       = ([A-Z][a-zA-Z_0-9-]*) $->0 spaces
		          <- [result asSymbol]
variable           = pronoun
		   | variableName
name		   = variable
		   | !keyword ([a-zA-Z_][a-zA-Z_0-9-]*) $->0 spaces
		          <- [result asSymbol]
nameExp            = lparen expr->0 rparen
  		          <- [self @ '0] 
		   | variable
		   | name
		          <- `',result
nameExpCompiled    = lparen exprCompiled->0 rparen
  		          <- [self @ '0] 
		   | variable
		   | name
		          <- `',result
variableExp        = lparen expr->0 rparen
  		          <- [self @ '0] 
		   | pronoun
		   | variable
			  <- `',result
variableExp2       = lparen expr->0 rparen
  		          <- [self @ '0] 
		   | variable
nameExps           = nameExp->0 nameExp+->1
		          <-  [Array with: [self @ '0] withAll: [self @ '1]]
symbol		   = number
  		   | name
		   | string
symbolCompiled     = symbol
                          <- [result asString]
qualifiable        = type | name
drawable	   = variable
		   | nameExp 
		   | stringExp
		   | expr
commaAndValue      = comma expr->0
		            <- [self @ '0]
commaSeparatedValues = expr->0 commaAndValue*->1
		            <- [OrderedCollection with: [self @ '0] withAll: [self @ '1]]
                   | ''
			    <- [OrderedCollection new]
list		   = spaces lbrackets commaSeparatedValues->0 rbrackets
		     	    <- `(make-collection List ,@[self @ '0])
set		   = spaces lbraces commaSeparatedValues->0 rbraces
		     	    <- `(make-collection Set ,@[self @ '0])
listCompiled	   = spaces lbrackets commaSeparatedValues->0 rbrackets
		     	    <- `[(make-collection List ,@[self @ '0]) compiled]
setCompiled	   = spaces lbraces commaSeparatedValues->0 rbraces
		     	    <- `[(make-collection Set ,@[self @ '0]) compiled]
primitiveCollection = list | set
primitiveCollectionCompiled = listCompiled | setCompiled
collection         = primitiveCollection
		   | setOfObjects
collectionCompiled = primitiveCollectionCompiled
		   | setOfObjectsCompiled
constantValue      = (boolean | symbol)
		          <- `',result
		   | primitiveCollection
constantValueCompiled = (boolean | symbolCompiled)
		          <- `',result
		   | primitiveCollectionCompiled
primitiveValue	   = variable 
		   | constantValue
primitiveValueCompiled = variable 
		   | constantValueCompiled
expressionValue    = setOfObjects | pickFromSetOfObjs | collectionCount | collectionSize
expressionValueCompiled = setOfObjectsCompiled | pickFromSetOfObjsCompiled 
                   | collectionIdxingCompiled | collectionIdxsCompiled 
                   | collectionLastIdxCompiled | collectionCountCompiled 
                   | collectionSizeCompiled 
propertyValNamePairs = primitiveValue->2 name->3
			     <- `(send '= (send ',[self @ '3] john-which 0) ,[self @ '2])->1
		       ( primitiveValue->2 name->3 
		             <- `(and ,[self @ '1] (send '= (send ',[self @ '3] john-which 0) ,[self @ '2]))->1 )*
		     	 <- [self @ '1]
	            | '' <- 0
propertyValNamePairsCompiled = primitiveValueCompiled->2 name->3
			     <- `(send '= (send ',[self @ '3] john-which 0) ,[self @ '2])->1
		       ( primitiveValueCompiled->2 name->3 
		             <- `(and ,[self @ '1] (send '= (send ',[self @ '3] john-which 0) ,[self @ '2]))->1 )*
		     	 <- [self @ '1]
	            | '' <- 0
setOfObjects        = all propertyValNamePairs->1 variable->0
		          <- `(filter-object-list ,[self @ '0] ,[self @ '1])
		   | select expr->0 by clauses->1
		          <- `(filter-collection-by ,[self @ '0] ,[self @ '1])
	           | number->0 spaces random (numberKeyword->1 <- '2->2 | variableName->1 <- '1-> 2 | expr->1 <- '0-> 2)
		     	  <- `(select-from-collection-by-random ',[self @ '0] ,[self @ '1] ,[self @ '2])
setOfObjectsCompiled = all numberKeyword 
                          <- `['u , [[solverInfo at: 'bounds] at: 'Integer]]
                   | all propertyValNamePairsCompiled->1 variable->0
		          <- `(filter-object-list-compiled ,[self @ '0] ,[self @ '1])
		   | select exprCompiled->0 by clausesCompiled->1
		          <- `(filter-collection-by ,[self @ '0] ,[self @ '1])
	           | number->0 spaces random (numberKeyword->1 <- '2->2 | variableName->1 <- '1-> 2 | exprCompiled->1 <- '0-> 2)
		     	  <- `(select-from-collection-by-random ',[self @ '0] ,[self @ '1] ,[self @ '2])
pickFromSetOfObjs  = article propertyValNamePairs->1 (collection->0 | numberKeyword->2 <- `[john-max-int random: '1]->0 | variable->2 <- `(filter-object-list ,[self @ '2] ,0)->0)
		     	  <- (if [self @ '1]
			     	 `(let ((l (filter-collection-by ,[self @ '0] ,[self @ '1])))
				       [l randomOne])				     
				     `[,[self @ '0] randomOne])
pickFromSetOfObjsCompiled = article propertyValNamePairsCompiled->1 (collectionCompiled->0 | numberKeyword->2 <- `[john-max-int random: '1]->0 | variable->2 <- `(filter-object-list-compiled ,[self @ '2] ,0)->0)
		     	  <- (if [self @ '1]
			     	 `(let ((l (filter-collection-by ,[self @ '0] ,[self @ '1])))
				       [l randomOne])				     
				     `[,[self @ '0] randomOne])
collectionCount    = pound expr->0 in expr->1
		          <- `[,[self @ '1] count: ,[self @ '0]]
collectionSize     = pound unaryPrimitive->0
		          <- `[,[self @ '0] size]
collectionCountCompiled = (pound exprCompiled->0 in exprCompiled->1 | unaryPrimitiveCompiled->1 'count:' spaces exprCompiled->0)
		          <- `(collection-count-compiled ,[self @ '0] ,[self @ '1]) 
collectionSizeCompiled = pound unaryPrimitiveCompiled->0
		          <- `(collection-size-compiled ,[self @ '0]) 
collectionIdxingCompiled = unaryPrimitiveCompiled->0 at colon 
                              (primitiveValueCompiled | exprCompiled->2 
                                   <- `['Int , (make-string-w-brackets ,[self @ '2])])->1
                          <- `(collection-indexing-compiled ,[self @ '0] ,[self @ '1])
collectionIdxsCompiled = unaryPrimitive->0 'indices' spaces
		          <- `(collection-indices-compiled ,[self @ '0]) 
collectionLastIdxCompiled = unaryPrimitive->0 'lastIndex' spaces
		          <- `(collection-lastIndex-compiled ,[self @ '0]) 
slctrWithArg       = msgNamesAndArgVal+->3
                          <- (let ((argVals [[self @ '3] applyMsgsAndMap: [Array with: 'second]])
				   (argMsgNames [[self @ '3] applyMsgsAndMap: [Array with: 'first]]))
			       [Array with: [argMsgNames toSymbol] with: argVals])
slctrWithArgCompiled = msgNamesAndArgValCompiled+->3
                          <- (let ((argVals [[self @ '3] applyMsgsAndMap: [Array with: 'second]])
				   (argMsgNames [[self @ '3] applyMsgsAndMap: [Array with: 'first]]))
			       [Array with: [argMsgNames toSymbol] with: argVals])
msgSend		   = (at time number->2 | '' <- 0->2) unaryPrimitive->0 
                        ( slctrWithArg->1 <- `(send ',[[self @ '1] at: '0] ,[self @ '0] ,@[[self @ '1] at: '1] ',[self @ '2])->0
                        | nameExp->1 <- `(send ,[self @ '1] ,[self @ '0] ',[self @ '2])->0)+
			 	   <- [self @ '0] 
msgSendCompiled	   = (at time number->2 | '' <- 0->2) unaryPrimitiveCompiled->0 
                        ( slctrWithArgCompiled->1 <- `(send-compiled ',[[self @ '1] at: '0] ,[self @ '0] ,@[[self @ '1] at: '1] ',[self @ '2])->0
                        | nameExpCompiled->1 <- `(send-compiled ,[self @ '1] ,[self @ '0] ',[self @ '2])->0)+
			 	   <- [self @ '0] 
unaryPrimitive     = lparen expr->0 rparen
  		          <- [self @ '0]
		   | primitiveValue
unaryPrimitiveCompiled = lparen exprCompiled->0 rparen
  		          <- [self @ '0]
		   | primitiveValueCompiled
multinaryPrimitive = expressionValue
		   | msgSend
multinaryPrimitiveCompiled = expressionValueCompiled
		   | msgSendCompiled
primitive	   = multinaryPrimitive
		   | unaryPrimitive
primitiveCompiled = multinaryPrimitiveCompiled
		   | unaryPrimitiveCompiled
numberExprCompiled = number | collectionSizeCompiled | collectionCountCompiled
                   | collectionIdxsCompiled | collectionLastIdxCompiled
parenPrimitiveCompiled = numberExprCompiled
                   | primitiveCompiled
                          <- `(make-string-2 'sum (make-string-w-parens ,result))
multExpr	   = (primitive->0 
		          <- [self @ '0])->1
		          (mathMultOp->2 primitive->3 
			        <- `(send ',[self @ '2] ,[self @ '1] ,[self @ '3]) -> 1)*
  		          	       <- [self @ '1]
multExprCompiled  = primitiveCompiled->1 !(mathMultOp|mathAddOp) | 
                     ( (parenPrimitiveCompiled->0 
		          <- [self @ '0])->1
		          (mathMultOp->2 parenPrimitiveCompiled->3 
			        <- `(make-string-3-w-parens ,[self @ '1] ',[self @ '2] ,[self @ '3]) -> 1)* )
  		          	       <- [self @ '1]
parenExprCompiled  = numberExprCompiled
                   | exprCompiled
                          <- `(make-string-2 'sum (make-string-w-parens ,result))
expr	 	   = (multExpr->0 
		          <- [self @ '0])->1
		          (mathAddOp->2 multExpr->3 
			        <- `(send ',[self @ '2] ,[self @ '1] ,[self @ '3]) -> 1)*
  		          	       <- [self @ '1]
exprCompiled	 	   = (multExprCompiled->0 
		          <- [self @ '0])->1
		          (mathAddOp->2 multExprCompiled->3 
			        <- `(make-string-3-w-parens ,[self @ '1] ',[self @ '2] ,[self @ '3]) -> 1)*
  		          	       <- [self @ '1]
higherOrderClause  = for (every | any)->0 variable->3 in expr->1 suchThat clauses->2
                          <- `(quantify-clause ',[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3])
higherOrderClauseCompiled = for (every | any)->0 variable->3 in exprCompiled->1 suchThat clausesCompiled->2
                          <- `(quantify-clause-compiled ',[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3])
clause	     	   = not clause->0
		          <- `(not ,[self @ '0])
		   | higherOrderClause
  		   | expr->0 mathCompOp->1 expr->2
		          <- `(send ',[self @ '1] ,[self @ '0] ,[self @ '2])
  		   | expr->0 in expr->1
		          <- `[,[self @ '1] includes: ,[self @ '0]]
                   | lparen clauses->0 rparen
  		          <- [self @ '0]
	           | upon variableExp2->0 do name->1 unaryPrimitive*->2 suchThat clauses->3
  		          <- `(upon-action-clause ,[self @ '0] ,[[self @ '1] , '-no-rule-check] ,[self @ '2] ,[self @ '3])
		   | boolean
                   | primitive
clauseCompiled     = not clauseCompiled->0
		          <- `(not ,[self @ '0])
		   | higherOrderClauseCompiled
  		   | parenExprCompiled->0 mathCompOp->1 parenExprCompiled->2
		          <- `(make-string-3-w-parens ,[self @ '0] ',[self @ '1] ,[self @ '2])
  		   | exprCompiled->0 in exprCompiled->1
		          <- `[,[self @ '1] includes: ,[self @ '0]]
                   | lparen clausesCompiled->0 rparen
  		          <- [self @ '0]
	           | upon variableExp2->0 do name->1 unaryPrimitiveCompiled*->2 suchThat clausesCompiled->3
  		          <- `(upon-action-clause ,[self @ '0] ,[[self @ '1] , '-no-rule-check] ,[self @ '2] ,[self @ '3])
		   | boolean
                   | primitiveCompiled
clauses	     	   = (clause->0 
		          <- [self @ '0])->1
		          (logicOp->2 clause->3  
          // this is alex's genious method to work around and/or returning '0 on true:
                                <- `(* john-true (,[self @ '2] ,[self @ '1] ,[self @ '3])) -> 1)*
  		          	       <- [self @ '1]
clausesCompiled	   = (clauseCompiled->0 
		          <- [self @ '0])->1
		          (logicOpCompiled->2 clauseCompiled->3  
                                <- `(make-string-3 ,[self @ '1] ',[self @ '2] ,[self @ '3]) -> 1)*
  		          	       <- [self @ '1]
predicate	   = is clauses->0
  		          <- `(predicate ,[self @ '0])
predicateCompiled  = is clausesCompiled->0
  		          <- `(predicate ,[self @ '0])
qualifyValPred     = is clauses->0
		     	  <- [Array with: [self @ '0] with: 0]
		   | expr->0 (is clauses->1 | '' <- 0->1)
		     	  <- [Array with: [self @ '0] with: [self @ '1]]
qualifyValPredCompiled = is clausesCompiled->0
		     	  <- [Array with: [self @ '0] with: 0]
		   | exprCompiled->0 (is clausesCompiled->1 | '' <- 0->1)
		     	  <- [Array with: [self @ '0] with: [self @ '1]]
nameAndVariable    = name->0 colon variable->1
		     	  <- [Array with: [self @ '0] with: [self @ '1]]
classAndVariable   = variable->0 colon variable->1
		     	  <- [Array with: [self @ '0] with: [self @ '1]]
msgNamesAndArgVal  = name->0 colon unaryPrimitive->1
		     	  <- [Array with: [self @ '0] with: [self @ '1]]
msgNamesAndArgValCompiled = name->0 colon unaryPrimitiveCompiled->1
		     	  <- [Array with: [self @ '0] with: [self @ '1]]
assignmentObject   = ( (lparen msgSend->0 rparen | nameExp->0) ((nameExp->1 !!nameExp) 
		          <- `(send ,[self @ '1] ,[self @ '0] john-nil)->0 )* )
  		                  <- [self @ '0]
assignmentProperty = nameExp
assignment	   = ( ( assignmentObject->0 assignmentProperty->2 at primitive->1 assign ( expr->6 <- `(let ((col (send ,[self @ '2] ,[self @ '0] ',john-nil))
                                 (colCp [col copy]))
                                [colCp at: ,[self @ '1] put: ,[self @ '6]]
                                colCp)-> 3 )
                          | assignmentObject->0 assignmentProperty->2 assign expr->3 )
			| lparen assignments->5 rparen
                        | actionRun->5 ) (is clause->4 | '' <- 0->4)
  		          <- (let ((updateExp (if [self @ '5]
			     	  	      	  [self @ '5]
			     	  	          `[[johnCurrently currentWorld]
				   	      		  update: ,[self @ '0]
				   	      		  property: ,[self @ '2]
							  value: ,[self @ '3]])))
				    (if [self @ '4]
				    	`(if ,[self @ '4] ,updateExp)
					updateExp))		   
assignments	   = (assignment->0 
		          <- [Expression withAll: `(let()) with: [self @ '0]])->1
		          (logicAndOp->2 assignment->3 
				<- [Expression withAll: [self @ '1] with: [self @ '3]] -> 1)*
  		          	       <- [self @ '1]
explicitAssignment = assignment->0
                          <- `(explicit-assignment ,[self @ '0])
visualInfo	   = (at xcoord number->0 ycoord number->1 | '' <- 0->0 '' <- 0->1) draw drawable+->2
		     	  <- `(make-drawing ,[self @ '0] ,[self @ '1] ,[self @ '2])
                   | for every->0 variable->3 in expr->1 do visualInfo->2
                          <- `(for-loop ',[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3])
visualInfos	   = (visualInfo->0 
		          <- [Expression withAll: `(let()) with: [self @ '0]])->1
		          (logicAndOp->2 visualInfo->3 
				<- [Expression withAll: [self @ '1] with: [self @ '3]] -> 1)*
  		          	       <- [self @ '1]

query		   = predicate | expr
timeQuery	   = time endword
		     	  <- `[[johnCurrently currentWorld] time]
worldDump          = world endword
		     	  <- `[[[johnCurrently currentWorld] instancePropertyValues] printlnMe]
qualify            = 'qualify' endword <- `(let())->4
                        qualifiable->0 (name->1 !colon <- 0->3 | nameAndVariable+->3 <- [[[self @ '3] applyMsgsAndMap: [Array with: 'first]] toSymbol]->1) 
                          (qualifyValPred->2
                              <- [Expression withAll: [self @ '4] with: `(qualify-type-or-class ,[self @ '0] ,[self @ '1] ,[[self @ '2] at: '0] ,[[self @ '2] at: '1] ,[self @ '3])]->4 (comma|!!dot))+ 
                                  <- [self @ '4]
qualifyCompiled    = 'qualify' endword <- `(let())->4
                        qualifiable->0 (name->1 !colon <- 0->3 | nameAndVariable+->3 <- [[[self @ '3] applyMsgsAndMap: [Array with: 'first]] toSymbol]->1) <- [[solverInfo at: 'compiled-msg-sends] at: [self @ '1] put: '1]
                     // for compiled ver also define-send compiled_<type>_<name> for the symbol type!
                          (qualifyValPredCompiled->2
                              <- [Expression withAll: [self @ '4] with: `(let () (extra-qualify-for-symbol-compiled ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3]) (qualify-type-or-class ,[self @ '0] ,['compiled_ , [self @ '1]] ,[[self @ '2] at: '0] ,[[self @ '2] at: '1] ,[self @ '3]))]->4 (comma|!!dot))+ 
                                  <- [self @ '4]
qualify2           = !!qualify->0 qualifyCompiled->1 // parse qualify twice, 2nd time for compiled ver
                                  <- `(let () ,[self @ '0] ,[self @ '1])
startWorld         = 'start-world' endword name->0
                          <- `(start-world ,[self @ '0])
contWorld          = 'continue-world' endword name->0
                          <- `(cont-world ,[self @ '0])
createClass        = 'class' endword variable->0 (colon
                          (((fullType|variable)->2 | '') name->3 ( comma | spaces )
		     	      <- [Array with: [self @ '2] with: [self @ '3]])*->1 
                               | '' <- '()->1)
                                   <- `(create-class ,[self @ '0] ,[self @ '1])
groupClasses       = 'group' endword variable->0 variable->1 variable+->2
                          <- `(create-group ,[self @ '0] ,[OrderedCollection with: [self @ '1] withAll: [self @ '2]])
makeObj            = 'make' endword variable->0 variableExp->1 unaryPrimitive*->2
                          <- `(make-object ,[self @ '0] ,[self @ '1] ,[self @ '2])
actionDef          = 'action' endword name->0 name->1 classAndVariable*->2 consequence assignments->3
                          <- `(action-or-goal-def ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3] 1)
actionRule         = rule name->0 name->1 is clauses->2
                          <- `(action-rule ,[self @ '0] ,[self @ '1] ,[self @ '2])
goalDef            = 'goal' endword name->0 name->1 classAndVariable*->2 clauses->3
                          <- `(action-or-goal-def ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3] 0)
goalDefCompiled    = 'goal' endword name->0 name->1 classAndVariable*->2 clausesCompiled->3
                          <- `(qualify-type-or-class ,[self @ '0] ,['compiled_goal_ , [self @ '1]] ,[self @ '3] ,john-nil ,[self @ '2])
goalDef2           = !!goalDef->0 goalDefCompiled->1 // parse twice 2nd time for compiled
                          <- `(let () ,[self @ '0] ,[self @ '1])
goalHeuristic      = 'heuristic' endword name->0 name->1 (number->2 | '' <- '1->2) (exprHeuristicType->3 expr->4 | predHeuristicType->3 clauses->4)
                          <- `(goal-heuristic ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3] ,[self @ '4])
goalOptimization   = 'goal-optimization' endword name->0 name->1 name->2 explicitAssignment->3
                          <- `(goal-optimization ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3])
goalSatOptimization  = 'goal-sat-optimization' endword name->0 name->1 use name->2 is clauses->3
                          <- `(goal-sat-optimization ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3])
actionOptimization = 'action-optimization' endword name->0 name->1 staticDynamicType->4 (establish clauses->2 <- 1->3 | use expr->2 <- 0->3)
                          <- `(action-optimization ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3] ,[self @ '4])
actionRun         = variableExp2->0 do name->1 unaryPrimitive*->2
		          <- `(action-run ,[self @ '0] ,[self @ '1] ,[self @ '2])
goalRun           = variableExp2->0 satisfy name->1 unaryPrimitive*->2 (by variable+->3 | '' <- 0->3) (using name+->4 | '' <- 0->4)
		          <- `(goal-run ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3] ,[self @ '4])
goalSolve         = variableExp2->0 solve name->1 unaryPrimitive*->2 (by variable+->3 | '' <- 0->3) (using name+->4 | '' <- 0->4)
		          <- `(goal-solve ,[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3] ,[self @ '4])
visualDef          = 'visual' endword name->0 visualInfos->1
		     	  <- `(visual-def ,[self @ '0] ,[self @ '1])
drawObj		   = visualInfos->0
			  <- `(draw-items ,[self @ '0])
setBounds          = 'bound' endword variable->0 spaces lbrackets number->1 comma number->2 rbrackets
		          <- `(set-bounds ,[self @ '0] ,[self @ '1] ,[self @ '2])
setOpt             = 'set-opt' endword name->0 primitiveValue->1
		          <- `(set-opt ,[self @ '0] ,[self @ '1]) 
higherOrderCmd     = for every->0 variable->3 in expr->1 do (makeObj | drawObj | query)->2
                          <- `(for-loop ',[self @ '0] ,[self @ '1] ,[self @ '2] ,[self @ '3])
sentence           = ( startWorld | contWorld | createClass | groupClasses 
                       | makeObj | actionDef | actionRule | goalDef2
		       | goalHeuristic | goalOptimization | goalSatOptimization 
                       | actionOptimization | qualify2
		       | visualDef | timeQuery | drawObj | setBounds | setOpt 
                       | worldDump | higherOrderCmd )
		          <- [Array with: result with: 0] 
		    |  ( actionRun | goalRun | goalSolve | explicitAssignment | query )
		          <- [Array with: result with: 1] 
program            = spaces ( sentence->0 
		     	    	  <- (eval-sentence [[self @ '0] at: '0] [[self @ '0] at: '1]) 
				     dot spaces | !theEnd error )* 
				  spaces theEnd
                          <- '0

} name: 'john]


;; this grammar to parse output from solver 
['{

error		   = <- [self error: '"syntax error"]
eol		   = '\r' '\n'* | '\n' '\r'*
space		   = [ \t] | eol
spaces		   = space*
end	           = !.
lbraces		   = '{' spaces
rbraces		   = '}' spaces
lbrackets	   = '[' spaces
rbrackets	   = ']' spaces
comma		   = ',' spaces
equals		   = '=' spaces
varName		   = ([a-zA-Z_][0-9]+)$->0 spaces
		          <- [result asSymbol]
name		   = [a-zA-Z_]([0-9]+)$->0 spaces
		          <- [Integer fromString: [self @ '0]]
item               = lbrackets name comma name->0 rbrackets
                          <- result
items              = item->0 <- [List with: [self @ '0]]->1 
                          (comma item->2 <- [List withAll: [self @ '1] with: [self @ '2]]->1)*
                              <- [self @ '1]
list               = lbrackets items rbrackets
relation           = varName->0 equals list->1
                          <- [Array with: [self @ '0] with: [self @ '1]]
relations          = relation->0 <- `(,[self @ '0])->1 (comma relation->2 <-[Expression withAll: [self @ '1] with: [self @ '2]]->1)*
                          <- [self @ '1]
header             = spaces '*** PROBLEM 1 ***' spaces
outcome            = '---OUTCOME---' spaces ('TRIVIALLY_'|'')
unsatOutcome       = outcome 'UNSATISFIABLE' spaces
                          <- john-false
satOutcome         = outcome 'SATISFIABLE' spaces
                          <- john-true
instance           = '---INSTANCE---' spaces 'relations:' spaces lbraces relations->0 rbraces spaces
                        <- (let ((rels [self @ '0]) (vars [solverInfo at: 'vars])
				 (atoop [solverInfo at: 'atoop]) (j '0)
				 (unknowns [solverInfo at: 'unknowns])) 
			     (while [j < [rels size]]
				    (let ((rel [rels at: j]) (relN [rel first]))
				      (if [unknowns includesKey: relN]
					  (let ((val [rel second]) 
						(var [vars at: [atoop at: relN]])
						(unknown [unknowns at: relN]))
					    (send 'set:value: 
                                                  [unknown first] [unknown second] val))))
				    (set j [j + '1]))
			     rels)
stats              = '---STATS---' spaces .*
output             = header (unsatOutcome->0 <- [solverInfo at: 'outcome put: john-false] |
                             satOutcome->0 <- [solverInfo at: 'outcome put: john-ok] 
			          instance->1) stats end
                        <- '0

} name: 'solver]
