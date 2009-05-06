;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                               ;;;
;;;  SOL Language Interpreter                                     ;;;
;;;                                                               ;;;
;;; Author:        Hesam Samimi                                   ;;;
;;;                                                               ;;;
;;; Revision:      # 104                                          ;;;
;;; Last Update:   05-30-2008                                     ;;; 
;;;                                                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                               ;;;
;;; Instructions:                                                 ;;;
;;;   1. Load this file in common lisp interpreter                ;;;
;;;   2a. To start interpreter without pre-loading any program:   ;;; 
;;;         (sol)                                                 ;;;
;;;   2a. To pre-load your sol program first:                     ;;; 
;;;         (sol <your-program.sol>)                              ;;;
;;;                                                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; for faster loading using fn's below
;; replace with your own path:
;; (load "/Users/hesam/Desktop/Research/soracle/webpage/sol/src/sol.lsp")
(defconstant inp-file-short "prolog-robot.sol")
(defconstant sol-path "/Users/hesam/Desktop/Research/soracle/webpage/sol")
(defconstant sol-src-file "sol.lsp")
(defconstant inp-file (concatenate 'string 
				   sol-path
				   "/samples/" 
				   inp-file-short))
(defconstant lsp-file (concatenate 'string
				   sol-path
				   "/src/"
				   sol-src-file))

;; short fn's for load and run
(defun x ()
  (load lsp-file)
  (x2))

(defun x2 ()
  (sol inp-file))

;; short fn load
(defun l ()
  (load lsp-file))

;; short fn run
(defun r ()
  (sol-read-file inp-file))

(defun sol (&optional sol-code)
  (reset-vars)
  (if sol-code (sol-read-file sol-code))
  (loop 
   (format t "~%> ")
   (let ((cmd (read)))
     (if (not (listp cmd))
	 (print "commands need to be inside ()")
       (let ((1st (car cmd)))
	 ;; comment
	 (cond ((eq 1st '/) '())
	       ((my-member 1st '(q quit exit bye abort halt)) 
		(let ((x 1)) (reset-vars) (return)))
	       (t (sol-h cmd t))))))))

(defun sol-read-file (sol-code)
  (with-open-file (infile sol-code)		 
		  (loop 
		   (let* ((cmd (read infile)))
		     ;; comment
		     (cond ((eq (car cmd) '/) '())
			   ((eq (car cmd) 'end-file) (return))
			   (t (sol-h cmd '())))))))

(defun sol-h (cmd no-print)
  (and (or no-print (print cmd))
       (let* ((function-parsed (run-cmd cmd))
	      (ret-val (car function-parsed)) 
	      (msg (cadr function-parsed))
	      (msg-vars (or (caddr function-parsed) '()))
	      (list-msg-var (or (caddr (cdr function-parsed)) '()))
	      (msg-var1 (or (car msg-vars) '())) ;; right now upto 5 vars in format msg
	      (msg-var2 (or (cadr msg-vars) '()))
	      (msg-var3 (or (caddr msg-vars) '()))
	      (msg-var4 (or (cadddr msg-vars) '()))
	      (msg-var5 (or (cadddr (cdr msg-vars)) '())))	 
	 (if msg
	     (let ((x 1))
	       (format t 
		       msg msg-var1 msg-var2 msg-var3 msg-var4 msg-var5)
	       (if list-msg-var (print-list list-msg-var)))))))
  
(defun run-cmds (cmds)
  (cond ((null cmds) '())
	(t (let ((x 1))
	     (run-cmd (car cmds))
	     (run-cmds (cdr cmds))))))

(defun run-cmd (cmd)
  (let ((1st (car cmd)) (2nd (cadr cmd)) (2nd-on (cdr cmd)) (3rd-on (cddr cmd)))
          
    (cond 
	  ;; start-world: creating a new world
	  ((eq 1st 'start-world) 
	   (update-soracle 2nd '() '() '() '() '() '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ((eq 1st 'continue-world) 
	   (update-current-world 2nd)
	   (list 0 "~%ok."))
	  ((eq 1st 'list)
	          ;; list soracle!
	   (cond ((eq 2nd 'soracle)
		  (list 0  "~%Here it is: ~s" (list soracle)))
		 ((eq 2nd 'instance)
		  (list 0 "~%Here it is: ~s" (list instance-list)))
		 ((eq 2nd 'world)
		  ;; list world: listing known worlds
		  (list 0 "~%I know about these worlds: ~s" (list (list-worlds))))
		  ;; list object all: listing properties of all instances of 
		  ;; all known objects in a world
		  ((and (eq 2nd 'object) 3rd-on (eq (car 3rd-on) 'all))
		   (list-instances-properties-of-all-object current-world)
		   (list 0))
		  ;; list object: listing known objects in a world
		 ((eq 2nd 'object)		  
		  (list 0 "~%World ~s consists of these objects: ~s" 
				  (list current-world
					(list-objects current-world))))
		 ((is-object 2nd)
		  (let ((3rd (car 3rd-on)))
		    (cond 
		     ;; list all <instances> and their <properties> of the object
		     ((equal 3rd 'all) 
		      (list 0 "~%These are the ~ss: ~s"
				      (list 2nd
					    (list-instances-properties 2nd))))
		     ;; list <object> groups: listing groups of an object
		     ((equal 3rd 'group)
		      (list 0 "~%~s belongs to these objects: ~s"
				      (list 2nd
					    (object-groups 2nd))))
		     ;; list <object> subobject: listing subobjects of an object
		     ((equal 3rd 'subobject)
		      (list 0 "~%~s has these sub objects: ~s"
				      (list 2nd
					    (subobject-knowledge 2nd))))
		     ;; list <object> instance: listing instances of an object
		     ((equal 3rd 'instance)
		      (list 0 "~%These are the ~ss: ~s"
				      (list 2nd
					    (list-instances current-world 2nd))))
		     ;; list <object> property: listing properties of an object
		     ((equal 3rd 'property)
			   (list 0 "~%These are the ~s properties: ~s"
					   (list 2nd
						 (property-knowledge 2nd))))
		     ;; list <object> instance: listing instances of an object
		     ((equal 3rd 'qualification)
			   (list 0 "~%These are the ~s qualifications: ~s"
					   (list 2nd
						 (list-qualifications 2nd)))))))
		 ;; list <instance>: listing info on an instance of an object of a world
		 ((is-instance 2nd) (list 0 "~%These are properties of ~s: ~s"
						    (list 2nd
							  (list-instance-properties 2nd))))))
	  ;; for loop
	  ((and (eq 1st 'for) (eq 2nd 'all))
	   (run-cmds (translate-for-x-exps (list cmd) 'all))
	   (list 0 "~%ok"))
	  ;; select: selecting a subset of a set
	  ((equal 1st 'select)
	   (let ((ans (eval-select-exp 2nd-on)))
	      (list 0 "~%~s" (list ans))))
	  ;; create: new object definition
	  ((eq 1st 'create)
	   (update-soracle 
	    current-world 
	    (list 2nd (list '() (append 3rd-on (list 'type 'groups)) '() '() '() '()))
	    '() '() '() '() '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ;; group: defining subobjects of an object
	  ((eq 1st 'group)
	   (update-soracle 
	    current-world 
	    2nd '() '() '() '() '() '() 3rd-on '() '() '())
	   (list 0 "~%ok."))
	  ;; an is ...? predicate
	  ((eq 1st 'is)
	   (let ((3rd (car 3rd-on)) (4th (cadr 3rd-on)))
	     (list 0 "~%~s" (list (yes-or-no (eval-pred 2nd-on))))))
	  ;; qualify: adding a qualification (dynamic property) for an object
	  ((eq 1st 'qualify) 	   
	   (update-soracle current-world 2nd '() 3rd-on '() '() '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ;; relative qualify: adding a relative qualification between two (maybe same) objects
	  ((eq 1st 'rel-qualify) 	   
	   (update-soracle current-world '() '() '() '() '() '() 2nd-on '() '() '() '())
	   (list 0 "~%ok."))
	  ;; exp with all <object>
	  ((is-exp-with-all-object-token cmd)
	   (run-cmd (replace-all-object-tokens cmd)))	  	  
	  ;; nlp rule: adding a new enlgish nlp phrase rule for the world
	  ((and (eq 1st 'english) (eq 2nd 'phrase))
	   (update-soracle current-world '() '() '() '() '() '() '() '() 3rd-on '() '())
	   (list 0 "~%ok."))
	  ;; action definition
	  ((eq 1st 'action)
	   (update-soracle current-world 2nd '() '() (list 0 3rd-on) '() '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ;; action nlp definition
	  ((and (eq 1st 'english) (eq 2nd 'action) 
		(is-object (car 3rd-on)) (is-action (car 3rd-on) (cadr 3rd-on)))
	   (update-soracle current-world (car 3rd-on) '() '() (list 1 (cdr 3rd-on)) 
			   '() '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ;; action rule definition
	  ((eq 1st 'rule)
	   (cond ((is-action 2nd (car 3rd-on))
		  (update-soracle current-world 2nd '() '() (car 3rd-on) (list 0 (cddr 3rd-on))
				  '() '() '() '() '() '())
		  (list 0 "~%ok."))
		 (t (list 1 "~%sorry. no such action for ~s object." 
				 (list 2nd)))))
	  ;; action rule nlp definition
	  ((and (eq 1st 'english) (eq 2nd 'rule) 
		(is-object (car 3rd-on)) (is-action (car 3rd-on) (cadr 3rd-on)))
	   (update-soracle current-world (car 3rd-on) '() '() (cadr 3rd-on) (list 1 (cdddr 3rd-on))
			   '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ;; goal definition
	  ((eq 1st 'goal)
	   (update-soracle current-world 2nd '() '() '() '() '() '() '() '() (list 0 3rd-on) '())
	   (list 0 "~%ok.")) 
	  ;; goal nlp definition
	  ((and (eq 1st 'english) (eq 2nd 'goal) 
		(is-object (car 3rd-on)) (is-goal (car 3rd-on) (cadr 3rd-on)))
	   (update-soracle current-world (car 3rd-on) '() '() '() '() '() '() '() '() 
			   (list 1 (cdr 3rd-on)) '())
	   (list 0 "~%ok."))
	  ;; exp with a/an/the <adjecttives?> <object>: (put a green color block in the-box) 
	  ((is-exp-with-a-an-object-token cmd)
	   (let ((qualifiers-translated (is-exp-with-a-an-object-token cmd)))
	     ; not clear what "the" refers to:
	     (if (eq (car qualifiers-translated) 0)
		 (list 0 (list-to-string (append '(I don not know which) 
						 (cdr qualifiers-translated)
						 '(the refers to)))) 
	       (run-cmd qualifiers-translated))))
	  ;;  exp with random  
	  ((is-exp-with-random-object-token cmd)
	   (let ((qualifiers-translated (is-exp-with-random-object-token cmd)))
	     (run-cmd qualifiers-translated)))
	  ;; create: new instance creation
	  ((eq 1st 'make)
	   (update-soracle current-world 2nd 
			   (list (car 3rd-on) 
				 (list 
				  (append (cdr 3rd-on) (list 2nd) 
					  (list (list-to-set (object-groups 2nd))))
				  '()))
			   '() '() '() '() '() '() '() '() '())
	   (list 0 "~%ok."))
	  ;; performing an action
	  ((is-action-cmd cmd)
	   (let ((object (is-action (instance-object 1st) 2nd))
		 (instance 1st)
		 (action 2nd))	   
	     (let ((action-run (run-action instance action 3rd-on '())))
	       (if (car action-run)		  
		   (list 0 "~%ok.")	       
		 (list 1 "~%sorry. ~s action ~s does not allow this. violation is:~%~s" 
				 (list object action (cadr action-run)))))))
	  ;; undoing an action
	  ((is-undo-cmd 'action cmd)
	   (action-undo 1st (car 3rd-on))
	   (list 0 "~%ok."))
	  ;; undoing a goal
	  ((is-undo-cmd 'goal cmd)
	   (goal-undo 1st (car 3rd-on))
	   (list 0 "~%ok."))
	  ;; explaining an action
	  ((is-action-explain cmd)
	   (let* ((instance (cadr 3rd-on))
		  (object (is-action (instance-object instance) (caddr 3rd-on)))
		  (action (caddr 3rd-on))
		  (action-explain (run-action instance action (cdddr 3rd-on) t)))
	     (if (car action-explain)		  
		 (list 1 "~%~s can ~s because its rules are satisified:~%~s" 
		       (list instance (cddr 3rd-on) 
			     (plug-in-bindings-values
			      ;; bound object name to instance name, since its not in
			      ;; actions-vars
			      (cons object (action-var-knowledge object action))
			      (cons instance (cdddr 3rd-on))
			      (unparse-with-word 
			       (action-rule-knowledge object action) 'and))))
	       (list 1 "~%~s cannot ~s because of violation of:~%~s" 
		     (list instance (cddr 3rd-on) (cadr action-explain))))))
	  ;; explaining intent of a goal/action (parent goals)
	  ((is-action-subgoal-intent-explain cmd)
	   (let ((instance (cadr 3rd-on))
		 (intent (explain-action-subgoal-intent 3rd-on)))
	     (if intent (list 1 "~%because ~s has these goals:~%~s" (list instance intent))
	       (list 1 "~%actually ~s has no reason for that" (list instance intent)))))
	  ;; listing instance's goals
	  ((and (is-instance 1st) (equal 2nd 'goals))
	   (list 1 "~%~s's active goals are: ~s" 
			   (list 1st (list-active-goals 1st))))
	  ;; performing a goal
	  ((is-goal-cmd cmd)
	   (let ((object (is-goal (instance-object 1st) 2nd))
		 (instance 1st)
		 (goal 2nd))			     	   
	     (let* ((goal-vars (goal-var-knowledge object goal))
		    (goal-var-values (var-to-val-map goal-vars 3rd-on))
		    (goal-run (run-goal instance goal 3rd-on 
					(list-active-goals instance) '() '()))
		    (goal-cmd (cons goal 3rd-on))
		    (run-res (cadr goal-run)))
	       (cond ((= run-res 4)
		      (list 1 "~%ok, but ~s's goal~%~s~%was pre-satisified, because of violation of:~%~s" 
			    (list instance goal-cmd 
				  (list-to-string 
				    (car 
				     (try-to-nlp-ize-goal-action-list 
				      goal 
				      (list '(fixme))
				      object instance
				      goal-vars
				      goal-var-values (get-opt 'no-nlp)))))))
		     ((= run-res 3)
		      (if (equal (caaddr goal-run) 'want)
			  ;; this is a possible sub-goal for a goal, but it isnt the only choice
			  (list 1 "~%sorry. ~s does not currently have ~s sub-goal, because its parent goal:~%~s~%either is not active, or has other choices for a sub-goal:~%~s" 
			    (list instance goal-cmd (caddr goal-run) (caddr goal-run)))
			  ;; goal cant be active:when predicate (which isnt a subgoal) isnt true
			(list 1 "~%sorry. ~s does not currently have ~s goal. violation is:~%~s" 
			    (list instance goal-cmd (caaddr goal-run)))))
		     ((= run-res 0) ;; goal ran sucessfully
		      (let ((goal-nlp-ized (car (try-to-nlp-ize-goal-action-list
						 '()
						 (list goal-cmd)
						 object instance
						 goal-vars
						 goal-var-values '()))))
			;; de-activate the succeeded goal
			(deactivate-goal instance goal-cmd)
			(list 1 "~%ok. ~s performed these actions/goals:~%~s" 
			      (list instance (goal-list-to-nlp-paragraph 
					      (list goal-nlp-ized
						    (caddr goal-run)))))))
		     ((= run-res 1) ;; all trys failed
		      (let ((x 1))
			(goal-undo instance goal)
			(list 1 "~%sorry. ~s's goal ~s is not satisfiable right now. violtion is: ~%~s" 
			      (list instance goal (caddr goal-run)))))
		     ((= run-res 2)
		      ;; some precondition failed, goal is not runnable:
		      (list 1 "~%sorry. ~s goal ~s cannot be active. violation is:~%~s" 
				      (list object goal (caddr goal-run))))))))
	  ;; explaining a goal
	  ((is-goal-explain cmd)
	   (let ((instance (cadr 3rd-on))
		  (goal (caddr 3rd-on)))
	     (let* ((object (is-goal (instance-object instance) goal))
		    (goal-vars (goal-var-knowledge object goal))
		    (goal-var-values (var-to-val-map goal-vars (cdddr 3rd-on)))
		    (goal-explain (explain-goal instance goal (cdddr 3rd-on) 
						(list-active-goals instance) '() '()))
		    (goal-cmd (cons goal (cdddr 3rd-on)))
		    (explain-res (cadr goal-explain)))
	       (cond ((= explain-res 4)
		      (list 1 "~%ok, but ~s's goal~%~s~%was pre-satisified, because of violation of:~%~s" 
			    (list instance goal-cmd  
				  (list-to-string 
				   (car 
				    (try-to-nlp-ize-goal-action-list 
				      goal 
				      (list '(fixme))
				      object instance
				      goal-vars
				      goal-var-values (get-opt 'no-nlp)))))))
		     ((= explain-res 3)
		      (if (equal (caaddr goal-explain) 'want)
			  ;; this is a possible sub-goal for a goal, but it isnt the only choice
			  (list 1 "~%sorry. ~s does not currently have ~s sub-goal, because its parent goal:~%~s~%either is not active, or has other choices for a sub-goal:~%~s" 
			    (list instance goal-cmd (caddr goal-explain) (caddr goal-explain)))
			  ;; goal cant be active:when predicate (which isnt a subgoal) isnt true
			(list 1 "~%sorry. ~s does not currently have ~s goal. violation is:~%~s" 
			    (list instance goal-cmd (caaddr goal-explain)))))
		     ((= explain-res 0) ;; goal ran sucessfully
		      (let* ((goal-nlp-ized (car (try-to-nlp-ize-goal-action-list  
						  '()
						  (list goal-cmd)
						  object instance
						  goal-vars
						  goal-var-values '()))))
			(list 1 "~%~s can satisfy ~s by these actions/goals:~%~s" 
			      (list instance (cddr 3rd-on) (goal-list-to-nlp-paragraph 
							    (list goal-nlp-ized
								  (caddr goal-explain)))))))
		     ((= explain-res 1) ;; all trys failed
		      (let ((x 1))
			(goal-undo instance goal)
			(list 1 "~%~s's goal ~s is not satisfiable right now. violation is:~%~s" 
			      (list instance goal (caddr goal-explain)))))
		     ((= explain-res 2)
		      ;; some precondition failed, goal is not explainnable:
		      (list 1 "~%~s goal ~s cannot be satisfied, becuase of violation of:~%~s" 
			    (list object goal (caddr goal-explain))))))))
	  ;; explaining reason for a qualification
	  ((is-qualification-explain cmd)
	   (let* ((is-case (= 0 (is-qualification-explain cmd)))
		  (instance (if is-case (cadr 3rd-on) (caddr 3rd-on)))
		  (object (instance-object instance))
		  (qualification (if is-case (caddr 3rd-on) (cadddr 3rd-on)))
		  (explained (explain-qualification object qualification instance))
		  (qualification-value (car explained))
		  (qualification-reason (cadr explained)))	      
	     (cond ((and (equal qualification-value (last-element cmd))
			 is-case)
		    (list 1 "~%because: ~s" (list qualification-reason)))
		   ((and (not (equal qualification-value (last-element cmd)))
			 (not is-case))
		    (let ((not-qualification-reason 
			   (caddr (explain-not-qualification object qualification 
							     (last-element cmd) instance))))
		      (list 1 "~%because of violation of:~%~s" (list not-qualification-reason))))
		   (t (list 1 "~%actually ~s ~s is: ~s because: ~s" 
			    (list instance qualification qualification-value 
				  qualification-reason))))))
	  ;; explaining reason for a rel-qualification
	  ((is-rel-qualification-explain cmd)
	   (let* ((is-not-case (equal (cadr 3rd-on) 'not))
		  (clause (if is-not-case (cddr 3rd-on) (cdr 3rd-on)))
		  (rel-qualification-val-and-reason (explain-rel-qualification clause))
		  (rel-qualification-val (car rel-qualification-val-and-reason))
		  (rel-qualification-reason (caddr rel-qualification-val-and-reason)))
	     (cond ((and is-not-case rel-qualification-val)
		    (list 1 "~%actually~%~s, because: ~s" 
			  (list clause rel-qualification-reason)))
		   ((and (not is-not-case) (not rel-qualification-val))
		    (list 1 "~%actually that is not true, because: ~s" 
			  (list rel-qualification-reason)))
		   (is-not-case 
		    (list 1 "~%because of violation of:~%~s" (list rel-qualification-reason)))
		   (t (list 1 "~%because: ~s" (list rel-qualification-reason))))))
	  ;; activating qualified instance goals
	  ((and (is-instance 1st)
		(my-member 2nd '(activate-goals ags))) ;; fixme
	   (let ((activated (activate-qualified-goals 1st)))
	     (if activated
		 (list 0 "~%these new goals were activated for ~s: ~%~s" 
				 (list 1st activated))
	       (list 0 "~%no new goals can be activated for ~s." (list 1st)))))	  
	  ;; direct goal activation ;; hack fixme
	  ((and (is-instance 1st)
		(my-member 2nd '(activate-goal ag)))
	   (let ((activated (activate-goal 1st 3rd-on)))
	     (list 0 "~%ok.")))		 
	  ;; are we communicating in english (nlp)?
	  ((is-nlp-cmd cmd)
	   (let ((nlp-inp-and-vars-and-vals (is-nlp-cmd cmd)))
	     (nlp-respond cmd (car nlp-inp-and-vars-and-vals) 
			  (cadr nlp-inp-and-vars-and-vals)
			  (caddr nlp-inp-and-vars-and-vals))))
	  ;; an assignment (updating one property) 
	  ((is-info-cmd cmd)
	   (update-property-multi-times (list (cdr cmd)) '() '())
	   (list 0 "~%ok."))
	  ;; setting global options:
	  ;; turning no-nlp on:
	  ((eq 1st 'set-opt) (and (set-opt 2nd (car 3rd-on)) (list 0 "~%ok.")))
	  ;; default case : asking property or qualification of an instance or 
	  ;;                a math expression to evaluate
	  (t  (list 0 "~%~s" (list (eval-exp cmd)))))))
	  ;; unrecognized command
	  ;;(t (list 1 "I do not understand.")))))

;; pred  -> pred and pred | pred or pred | clause clause 
;; clause -> instance property | value   
(defun eval-pred (pred)
;  (print 'pred) (print pred) 
;  (print 'parse) (print (and-or-pred-parse pred))
  (eval-parsed-pred (and-or-pred-parse pred)))

(defun eval-parsed-pred (and-or-parsed)
    (cond 
     ((and (listp and-or-parsed) (null (cdr and-or-parsed)) (listp (car and-or-parsed)))
      (eval-parsed-pred (car and-or-parsed)))
     ((not (member (car and-or-parsed) log-ops)) ;; just one clause
	   (eval-clause and-or-parsed))
      ;; or/and clauses
     (t (let ((1st (eval-parsed-pred (cadr and-or-parsed))))
	  (cond ((eq (car and-or-parsed) 'and)
		 (cond ((unknownp 1st) unknown)
		       (1st (eval-parsed-pred (caddr and-or-parsed)))
		       (t '())))
		((eq (car and-or-parsed) 'or)
		 (cond ((and 1st (not (unknownp 1st))) t)
		       (t (eval-parsed-pred (caddr and-or-parsed))))))))))

(defun eval-clause (clause)
;  (print 'clause) (print clause)
  (let ((the-last-comp-op (last-comp-op clause)))
           ;; yes/no case
    (cond ((and (null (cdr clause)) (my-member (car clause) booleans))
	   (yes-no-to-bool (car clause)))
	  ;; not case
	  ((equal (car clause) 'not) (yes-no-unknown '() 
						     (eval-clause (cdr clause))
						     (not (eval-clause (cdr clause)))))
	  ;; for any clause case
	  ((and (equal (car clause) 'for) (equal (cadr clause) 'any))
	   (eval-pred (unparse-with-word (translate-for-x-exps (list clause) 'any) 'or)))
	  ;; for every clause case
	  ((and (equal (car clause) 'for) (equal (cadr clause) 'every))
	   (let ((exp-translated 
		  (unparse-with-word (translate-for-x-exps (list clause) 'every) 'and)))
	     (if (not exp-translated) t (eval-pred exp-translated))))
	  ;; upon clause: have to perform an action, check a pred, then undo.
	  ((equal (car clause) 'upon)
	   (let* ((upon-pred-parsed (split-on-first-word (cdr clause) 'do))
		  (action-to-do (car upon-pred-parsed))
		  (pred-to-check-upon-action (cadr upon-pred-parsed))
		  (action-done (run-cmd action-to-do)))
	         ;; was a valid action
	     (if (valid-cmd-ret-val action-done)
		 (let ((pred-evald (eval-pred pred-to-check-upon-action))
		       (action-undone (run-cmd (get-action-undo-cmd (car action-to-do)
								    (cadr action-to-do)))))
		   pred-evald)
	       ;; invalid action
	       unknown)))
	  ;; want goal question case (whether instance has such active goal)
	  ((and (equal (car clause) 'want) (is-instance (cadr clause)))
	   (is-active-goal 
	    (instance-object (cadr clause)) (cadr clause)
	    (cons (caddr clause)    ;; eval the goal vars fom when clause
		  (or (and (cdddr clause) (list (eval-exp (cdddr clause))))
		      '()))))
	  ;; relative qualification case
	  ((and (not (any-member math-comps clause))
		(any-member clause (list-rel-qualifications current-world)))
	   (let* ((rel-qualification-name 
		   (any-member clause (list-rel-qualifications current-world)))
		  (rel-qualification-clause-left-and-right 
		   (split-on-first-word clause rel-qualification-name))
		  (rel-qualification-translated 
		   (rel-qualification-to-direct-pred 
		    (list (eval-exp (car rel-qualification-clause-left-and-right))
			  rel-qualification-name
			  (eval-exp (cadr rel-qualification-clause-left-and-right))))))
	     (eval-pred rel-qualification-translated)))
	  ((eq the-last-comp-op '=)
	   (let* ((clause-left-and-right (split-on-last-word clause '=))
		  (left-evald (eval-exp (car clause-left-and-right)))
		  (right-evald (eval-exp (cadr clause-left-and-right))))
	     (if (and (setp left-evald) (setp right-evald))
		 (yes-no-unknown left-evald right-evald (equal-sets left-evald right-evald))
	       (yes-no-unknown left-evald right-evald (equal left-evald right-evald)))))
	  ((eq the-last-comp-op '>)
	   (let* ((clause-left-and-right (split-on-last-word clause '>))
		  (left-evald (eval-exp (car clause-left-and-right)))
		  (right-evald (eval-exp (cadr clause-left-and-right))))
	     (yes-no-unknown left-evald right-evald (> left-evald right-evald))))
	  ((eq the-last-comp-op '<)
	   (let* ((clause-left-and-right (split-on-last-word clause '<))
		  (left-evald (eval-exp (car clause-left-and-right)))
		  (right-evald (eval-exp (cadr clause-left-and-right))))
	     (yes-no-unknown left-evald right-evald (< left-evald right-evald))))
	  ((eq the-last-comp-op '>=)
	   (let* ((clause-left-and-right (split-on-last-word clause '>=))
		  (left-evald (eval-exp (car clause-left-and-right)))
		  (right-evald (eval-exp (cadr clause-left-and-right))))
	     (yes-no-unknown left-evald right-evald (>= left-evald right-evald))))
	  ((eq the-last-comp-op '<=)
	   (let* ((clause-left-and-right (split-on-last-word clause '<=))
		  (left-evald (eval-exp (car clause-left-and-right)))
		  (right-evald (eval-exp (cadr clause-left-and-right))))
	     (yes-no-unknown left-evald right-evald (<= left-evald right-evald))))
	  ((eq the-last-comp-op 'in)
	   (let* ((clause-left-and-right (split-on-last-word clause 'in))
		  (left-evald (eval-exp (car clause-left-and-right)))
		  (right-evald (eval-exp (cadr clause-left-and-right))))
	     (yes-no-unknown left-evald 
			     right-evald 
			     (set-member-or-subset left-evald right-evald))))
	  (t unknown))))

;; tells which exp caused the bool val 
(defun eval-pred-with-reason (pred)
  (eval-parsed-pred-with-reason (and-or-pred-parse pred) 0 '()))

(defun eval-parsed-pred-with-reason (and-or-parsed n no-n-incr)
  (cond  
   ((and (listp and-or-parsed) (null (cdr and-or-parsed))) 
    (eval-parsed-pred-with-reason (car and-or-parsed) n t))
   ((not (member (car and-or-parsed) log-ops)) ;; just one clause
    (let ((claused-evald (eval-clause and-or-parsed)))
      (cond ((unknownp claused-evald) (list unknown n and-or-parsed))
	    (claused-evald (list t n and-or-parsed))
	    (t (list '() n and-or-parsed)))))
   (t       ;; or/and clauses
    (let ((1st (eval-parsed-pred-with-reason (cadr and-or-parsed) n no-n-incr))
	  (incr (if no-n-incr n (+ n 1))))
      (cond ((eq (car and-or-parsed) 'and)
	     (cond ((unknownp (car 1st)) (list unknown n (cadr 1st)))
		   ((car 1st) (eval-parsed-pred-with-reason (caddr and-or-parsed) incr no-n-incr))
		   (t (list '() n (caddr 1st)))))
	    ((eq (car and-or-parsed) 'or)
	     (cond ((and (car 1st) (not (unknownp (car 1st)))) 
		    (list t n (cadr and-or-parsed)))
		   (t (eval-parsed-pred-with-reason (caddr and-or-parsed) incr no-n-incr))))
	    ((or (equal (car 1st) t) (equal (car 1st) '())) 1st (list n)))))))

(defun eval-pred-with-nlp-reason (pred object instance goal-or-action vars vals)
  (let* ((action-case (is-action object goal-or-action))
	 (val-and-reason-index-and-reason (eval-pred-with-reason pred))
	 (val (car val-and-reason-index-and-reason))
	 (reason-index (+ 1 (cadr val-and-reason-index-and-reason)))
	 (raw-rule-or-requires-knowledge 
	  (if action-case
	      (let ((raw-nlp-rule-or-requires-knowledge 
		     (action-nlp-rule-knowledge object goal-or-action)))
		(if raw-nlp-rule-or-requires-knowledge
		    raw-nlp-rule-or-requires-knowledge
		  (action-rule-knowledge object goal-or-action)))
	    (let ((raw-nlp-rule-or-requires-knowledge 
		   (goal-nlp-requires-knowledge object goal-or-action)))
		(if raw-nlp-rule-or-requires-knowledge
		    (list raw-nlp-rule-or-requires-knowledge)
		  (list (goal-requires-knowledge object goal-or-action))))))
	 (is-nlp-reason 
	  (or (and action-case 
		   (not (null (action-nlp-rule-knowledge object goal-or-action))))
	      (not (null (goal-nlp-requires-knowledge object goal-or-action)))))
	 (rule-or-requires-knowledge
	  (parse-on-word 
	   (car (unparse-with-word 
		 raw-rule-or-requires-knowledge 'and))
	   'and))
	 (maybe-nlp-reason 
	  (plug-in-bindings-values 
	   vars 
	   vals
	   (ith rule-or-requires-knowledge reason-index)))
	 (final-maybe-nlp-reason (if is-nlp-reason 
				     (list-to-string maybe-nlp-reason)
				   maybe-nlp-reason)))
    (list val final-maybe-nlp-reason)))

;; A or B -> (or (A) (B))
;; A or B or C -> (or (or A B) (C))
(defun and-or-pred-parse (pred)
      (and-or-pred-parse-h pred '()))

(defun and-or-pred-parse-h (pred a)
  (cond ((null pred) a)
	((equal (car pred) 'or)
	 (if a
	     (list 'or a (and-or-pred-parse (cdr pred)))
	     (append (list 'or) (listify-atoms (cdr pred)))))
	((equal (car pred) 'and)
	 (if a
	     (list 'and a (and-or-pred-parse (cdr pred)))
	     (append (list 'and) (listify-atoms (cdr pred)))))
	((atom (car pred)) 
	 (and-or-pred-parse-h (cdr pred) (append a (list (car pred)))))
	(t (and-or-pred-parse-h (cdr pred) (append a (list (and-or-pred-parse (car pred))))))))

(defun eval-exp (exp)
  (let ((ans (eval-parsed-math-exp (math-parse exp))))
    (if ans
	ans
      unknown)))

(defun eval-parsed-math-exp (math-parsed)
    (if (or (atom math-parsed) (not (member (car math-parsed) math-ops))) ;; just one clause
	(eval-single-exp math-parsed)
      ;; or/and clauses
      (let* ((1st (eval-parsed-math-exp (cadr math-parsed)))
	     (2nd (caddr math-parsed))
	     (2nd-to-use (if (numberp 2nd) 2nd (eval-parsed-math-exp 2nd))))
	(cond ((eq (car math-parsed) '+)
	       (cond ((and (setp 2nd-to-use) (setp 1st)) (set-add-set 1st 2nd-to-use))
		     ((setp 1st) (set-add-element 1st 2nd-to-use))
		     (t (+ 1st (eval-parsed-math-exp 2nd)))))
	      ((eq (car math-parsed) '-)
	       (cond ((and (setp 2nd-to-use) (setp 1st)) (set-subtract-set 1st 2nd-to-use))
		     ((setp 1st) (set-remove-element 1st 2nd-to-use))
		     (t (- 1st (eval-parsed-math-exp 2nd)))))
	      ((eq (car math-parsed) '*)
	       (* 1st (eval-parsed-math-exp 2nd)))
	      ((eq (car math-parsed) '/)
	       (/ 1st (eval-parsed-math-exp 2nd)))))))

(defun eval-single-exp (clause)
;  (print 'sc) (print clause)
  (cond ((atom clause) clause)
	((null (cdr clause)) (eval-single-exp (car clause)))
	(t (let ((1st (car clause)) (2nd (cadr clause)) 
		 (3rd (caddr clause)) (3rd-on (cddr clause)) (4th-on (cdddr clause)))
	     (cond ((equal 1st 'not) (yes-no-unknown '()
						     (eval-clause (cdr clause))
						     (not (eval-clause (cdr clause)))))
		   ;; asking set size
		   ((equal 1st 'size) (set-size (eval-single-exp (cdr clause)))) 
		   ;; making a subset of set using a predicate
		   ((equal 1st 'select)
                    (eval-select-exp (cdr clause)))		    
		   ;; asking all instances
		   ((and (equal 1st 'all) (is-object 2nd))
		    (list-to-set (list-instances current-world 2nd)))
		   ;; asking instances with certain adjectives (properties): all red color cube
		   ((and (equal 1st 'all) (is-object (last-element clause)))
		    (eval-single-exp (build-select-expression (cdr clause))))		   
		   ;; asking a number of random instances or elements  
		   ((eq 2nd 'random)
		    (n-random-instances-or-elements 3rd-on 1st))
		   ;; exp with a/an/the <adjecttives?> <object>: (a green color block) 
		   ((is-exp-with-a-an-object-token clause)
		    (let ((qualifiers-translated (is-exp-with-a-an-object-token clause)))
		      ; not clear what "the" refers to:
		      (if (eq (car qualifiers-translated) 0)
			  unknown 
			(eval-single-exp qualifiers-translated))))
		   (t (eval-single-exp (instance-property-recursive clause))))))))

(defun eval-select-exp (exp)
  (let ((select-cmd-parsed (split-on-last-word exp 'by)))
    (if (my-member (caar select-cmd-parsed) eng-articles)
	(car (set-to-list 
	      (eval-single-exp 
	       (list 1 'random 
		     (find-subset (eval-single-exp (cdar select-cmd-parsed))
				  (cadr select-cmd-parsed))))))
      (find-subset (eval-single-exp (car select-cmd-parsed))
		   (cadr select-cmd-parsed)))))

;; (a + b + c + d) -> ((+ a b) + c + d)  
;; A + B -> (+ (A) (B))
;; A - B + C -> (+ (- A B) (C))
(defun math-parse (exp)
  (cond ((null exp) '())
	((and (null (cdr exp)) (listp (car exp))) (math-parse (car exp)))
	(t (math-parse-h (math-parse-h2 exp '() '())))))

(defun math-parse-h (exp)
  (cond ((< (length exp) 3) exp)
	((member (cadr exp) math-ops) 
	 (if (null (cdddr exp))
	     (list (cadr exp) (car exp) (caddr exp))
	   (math-parse-h (cons (list (cadr exp) (car exp) (caddr exp)) (cdddr exp)))))
	((not (atom (car exp))) (math-parse-h (cons (append (car exp) (list (cadr exp)))
						    (cddr exp))))
	(t (math-parse-h (cons (list (car exp)) (cdr exp))))))

;; puts a () around non nums
(defun math-parse-h2 (exp vars ans)
  (cond ((null exp) (if (null vars) ans (append ans (list vars))))	
	((not (or (member (car exp) math-ops) 
		  (and (numberp (car exp)) 
		       (or (not (cdr exp)) (not (equal (cadr exp) 'random)))) ;;hack - fixme
		  (listp (car exp))))
	 (math-parse-h2 (cdr exp) (append vars (list (car exp))) ans))
	((listp (car exp)) 
	 (math-parse-h2 (cdr exp) (append vars (math-parse (car exp))) ans))
	((null vars) (math-parse-h2 (cdr exp) vars (append ans (list (car exp)))))
	(t (math-parse-h2 (cdr exp) '() (append ans (list vars (car exp)))))))

(defun parse-action-def (action object is-nlp-action)
  (let* ((split-keywords (if is-nlp-action '(means consequence) '(consequence)))
	 (action-split (split-on-all-these-words 
		      (cdr action) split-keywords))
	 (new-entry (if is-nlp-action
			(list (car action-split) ;vars
			      (cadr action-split) ;means
			      (action-nlp-rule-knowledge object action) ;rule
			      (parse-on-word (caddr action-split) 'and)) ;conseq
		      (list (car action-split) ;vars
			    '()
			    (parse-on-word (cadr action-split) 'and))))
	 (updated-action-sol (if is-nlp-action (get-action-sol object (car action)) new-entry))
	 (updated-action-nlp (if is-nlp-action new-entry '())))    
    (list (car action) 
	  (list 
	   updated-action-sol
	   updated-action-nlp))))

(defun parse-goal-def (goal object is-nlp-goal)
  (let* ((split-keywords (if is-nlp-goal (cons 'means goal-keywords) goal-keywords))
	 (goal-split (split-on-all-these-words 
		      (cdr goal) split-keywords))
	 (new-entry (if is-nlp-goal
			(list (car goal-split)
			      (cadr goal-split) 
			      (caddr goal-split) 
			      (cadddr goal-split) 
			      (parse-on-word (cadddr (cdr goal-split)) 'or)
			      (parse-on-word (cadddr (cddr goal-split)) 'and))
		      (list (car goal-split)
			    (cadr goal-split) 
			    (caddr goal-split) 
			    (parse-on-word (cadddr goal-split) 'or)
			    (parse-on-word (cadddr (cdr goal-split)) 'and))))
	 (updated-goal-sol (if is-nlp-goal (get-goal-sol object (car goal)) new-entry))
	 (updated-goal-nlp (if is-nlp-goal new-entry '())))    
    (list (car goal) 
	  (list 
	   updated-goal-sol
	   updated-goal-nlp))))



;; (make hand my-hand 5 random card) -> ((5 random card) (make hand my-hand))
(defun parse-exp-with-random (exp)
  (let ((rev-exp (reverse exp)))
    (list (list (caddr rev-exp) (cadr rev-exp) (car rev-exp))
	  (reverse (cdddr rev-exp))))) 

;(defun is-exp-with-all-object-token (exp)
;  (and (my-member 'all exp) (not (my-member 'for exp))))

(defun is-exp-with-all-object-token (exp)
  (cond ((null exp) '())
	((null (cdr exp)) '())
	((and (eq (car exp) 'for)
	      (eq (cadr exp) 'all))
	 (is-exp-with-all-object-token (cddr exp)))
	((and (eq (car exp) 'all)
	      (is-object (cadr exp))) t)
	(t (is-exp-with-all-object-token (cdr exp)))))

;; inp: (put a green color block in the-box)    
;; out: (put blockg in the-box)
;; inp: (a male sex "{ alice bob }" eats)
;; out: (bob eats)
(defun is-exp-with-a-an-object-token (exp)
  (let ((a-an-split (split-on-last-of-these-words exp eng-articles)))
    (if (not (cadr a-an-split))
	'()
      (let ((object (find-first-object-in-exp (cadr a-an-split)))
	    (some-set (find-first-set-in-exp (cadr a-an-split))))
	      ;; case 1: E.g. a blue color tall size lego <-- an object
	(cond (object (let* ((a-an-exp-split (split-on-sub-list exp (caadr a-an-split) object))
			     (qualified-set (eval-single-exp 
					     (build-select-expression (cdadr a-an-exp-split)))))
			(process-a-an-expression a-an-exp-split qualified-set object)))
	      ;; case 2: E.g. a blue color tall size the-box contains <-- a set
	      (some-set (let* ((the-set (car some-set)) 
			       (set-exp (if (null (cdr some-set)) 
					    (list the-set) (cadr some-set))))
			  (let* ((a-an-exp-split 
				(split-on-sub-list exp (caadr a-an-split) 
						   (last-element set-exp)))
				 (qualified-set (eval-single-exp
						 (build-select-expression 
						  (replace-sub-list (cdadr a-an-exp-split) 
								    set-exp
								    (list the-set))))))
			    (process-a-an-expression a-an-exp-split qualified-set the-set))))
	      (t '()))))))

(defun is-exp-with-random-object-token (exp)
  (let ((rand-split0 (split-on-last-of-these-words exp '(random))))

    (if (not (cadr rand-split0))
	'()
      (let*  ((rand-split (list (but-last (car rand-split0)) 
				(cons (last-element (car rand-split0)) (cadr rand-split0))))
	      (object (find-first-object-in-exp (cadr rand-split)))
	      (some-set (find-first-set-in-exp (cadr rand-split))))
	      ;; case 1: E.g. 2 random blue color tall size lego <-- an object
	(cond (object (let* ((rand-exp-split (split-on-sub-list exp (caadr rand-split) object))
			     (quantity (caadr rand-exp-split))
			     (qualified-set 
			      (eval-single-exp 
			       (build-select-expression (cddadr rand-exp-split)))))
			(process-rand-expression rand-exp-split qualified-set object quantity)))
	      ;; case 2: E.g. 1 random blue color tall size the-box contains <-- a set
	      (some-set (let* ((the-set (car some-set)) 
			       (set-exp (if (null (cdr some-set)) 
					    (list the-set) (cadr some-set)))
			       (quantity (caadr rand-split)))
			  (let* ((last-element-to-use (if (my-member 'select (cadr rand-split))
							  (last-element (cadr rand-split))
							(last-element set-exp)))
				 (rand-exp-split 
				  (split-on-sub-list exp (caadr rand-split) 
						     last-element-to-use))
				 (qualified-set (eval-single-exp
						 (build-select-expression 
						  (replace-sub-list (cddadr rand-exp-split) 
								    set-exp
								    (list the-set))))))
			    (process-rand-expression 
			     rand-exp-split qualified-set the-set quantity))))
	      (t '()))))))
	 
(defun n-random-instances-or-elements (object-or-set number)
  (let* ((object-or-set-evald (eval-single-exp object-or-set))
	 (instances-or-set (if (setp object-or-set-evald) 
			       (set-to-list object-or-set-evald)
			     (list-instances current-world object-or-set-evald))))
    (cond ((> number (length instances-or-set)) empty-set)
	  (t (list-to-set (n-random-instances-or-elements-h object-or-set-evald number '()))))))

(defun n-random-instances-or-elements-h (object-or-set number so-far)
  (cond ((= number 0) so-far)
	(t (let ((a-random-instance-or-element (random-instance-or-element object-or-set)))
	     (if (my-member a-random-instance-or-element so-far)
		 (n-random-instances-or-elements-h object-or-set number so-far)
	       (n-random-instances-or-elements-h 
		object-or-set 
		(- number 1) 
		(cons a-random-instance-or-element so-far)))))))

(defun random-instance-or-element (object-or-set)
  (let ((instances-or-set (if (setp object-or-set) 
			      (set-to-list object-or-set)
			    (list-instances current-world object-or-set))))
    (ith instances-or-set (+ 1 (random (length instances-or-set))))))

;; inp:blockr says  where is cubeg
;; out: ((block says where is lego) (block says where is cube)
;;       (lego says where is lego) (lego says where is cube))
(defun untranslate-instances-into-objects (exp)
  (let* ((instances (extract-instances exp))
	 (untrns (plug-in-bindings-values-full-cross-product 
		  instances
		  (possible-untranslations instances)
		  exp)))
    (or untrns (list exp))))

;; where is cubeg --> (cubeg)
(defun extract-instances (exp)
  (cond ((null exp) '())
	((is-instance (car exp))
	 (cons (car exp) (extract-instances (cdr exp))))
	(t (extract-instances (cdr exp)))))

;; where is cube --> (cube)
(defun extract-objects (exp)
  (cond ((null exp) '())
	((is-object (car exp))
	 (cons (car exp) (extract-objects (cdr exp))))
	(t (extract-objects (cdr exp)))))

(defun extract-nlp-inp-vars (nlp-inp sol-trans-inp)
  (let ((vars-and-objs (list-intersection nlp-inp sol-trans-inp)))
    (remove-objects-from-exp vars-and-objs)))

(defun remove-objects-from-exp (exp)
  (cond ((null exp) '())
	((is-object (car exp)) (remove-objects-from-exp (cdr exp)))
	(t (cons (car exp) (remove-objects-from-exp (cdr exp))))))

(defun extract-nlp-inp-var-vals (nlp-vars nlp-inp cmd)
  (cond ((null nlp-inp) '())
	((equal (car nlp-inp) (car nlp-vars))
	 (cons (car cmd) (extract-nlp-inp-var-vals (cdr nlp-vars) (cdr nlp-inp) (cdr cmd))))
	(t (extract-nlp-inp-var-vals nlp-vars (cdr nlp-inp) (cdr cmd)))))

;; ((FETCH FUEL) (FIND FUEL) (MOVETO BUILDING) (LEAVE))
;; --> ((object location) (fuel building))
(defun extract-action-goal-var-vals (object action-goal-list)
  (extract-action-goal-var-vals-h object action-goal-list '() '()))

(defun extract-action-goal-var-vals-h (object action-goal-list vars vals)
  (cond ((null action-goal-list) (list vars vals))
	(t (let* ((action-case (is-action object (caar action-goal-list)))
		  (goal-case (and (not action-case) 
				  (is-goal object (caar action-goal-list))))
		  (found-vars (cond (action-case 
				     (action-var-knowledge object (caar action-goal-list)))
				    (goal-case 
				     (goal-var-knowledge object (caar action-goal-list)))
				    (t '())))
		  (vals-to-use (if (or action-case goal-case) 
				   (append vals (list (cdar action-goal-list)))
				 vals)))
	     (extract-action-goal-var-vals-h 
	      object 
	      (cdr action-goal-list) 
	      (append vars (list found-vars))
	      vals-to-use)))))
 
;; (cubeg blockr) --> ((cube lego) (block lego))
(defun possible-untranslations (instances)
  (cond ((null instances) '())
	(t (let ((object (instance-object (car instances))))
	     (cons (cons object (object-groups object))
		   (possible-untranslations (cdr instances)))))))

(defun process-a-an-expression (a-an-exp-split qualified-set object-or-set)
  ;; "the" <object> case only makes sense if there is only one instance
  (if (and (my-member (caadr a-an-exp-split) eng-def-articles)
	   (< 1 (length (set-to-list qualified-set))))
      (list 0 object-or-set) 
    (append (car a-an-exp-split) 
	    (list (car (set-to-list 
			(eval-single-exp 
			 (list 1  'random qualified-set)))))
	    (caddr a-an-exp-split))))

(defun process-rand-expression (rand-exp-split qualified-set object-or-set quantity)
  ;; "the" <object> case only makes sense if there is only one instance
  (append (car rand-exp-split) 
	    (list (eval-single-exp 
		   (list quantity 'random qualified-set)))
	    (caddr rand-exp-split)))

;; inp: blue color tiny size block
;; out: select all block by of color = blue and of size = tiny
(defun build-select-expression (clause)
  (cond ((null (cdr clause)) (if (setp (car clause)) 
				 (list (car clause)) 
			       (list 'all (car clause))))	
	;; this is already select exp:
	((equal (car clause) 'select) clause)
	(t (append (list 'select)
		   (build-select-expression (cddr clause))
		   (list 'by 'of (cadr clause) '= (car clause))))))

(defun translate-for-x-exps (exps x)
  (cond ((null exps) '())
	((and (eq (caar exps) 'for) (equal (cadar exps) x))
	 (append (translate-for-x-exps (translate-for-x-single-exp (car exps) x) x)
		 (translate-for-x-exps (cdr exps) x)))
	(t (cons (car exps) (translate-for-x-exps (cdr exps) x)))))

(defun translate-for-x-single-exp (exp x)
  (cond ((and (eq (car exp) 'for) (equal (cadr exp) x))
	 (let* ((for-x-exp-parsed (split-on-first-word (cddr exp) 'do))
		(for-x-set-or-object-evald (eval-single-exp (car for-x-exp-parsed)))
		(for-x-rest (cadr for-x-exp-parsed)))
	   ;; is it for all <object> or for all <set> case
	   (if (setp for-x-set-or-object-evald)
	       (plug-in-bindings-values-cross-product 'of
						      (set-to-list for-x-set-or-object-evald) 
						      for-x-rest)
	     (plug-in-bindings-values-cross-product for-x-set-or-object-evald
						    (list-instances current-world (caddr exp)) 
						    for-x-rest))))
	(t exp)))

;; (A B C D E F D) --D--> ((A B C) (E F D))
(defun split-on-last-word (list word)
  (split-on-last-word-h list word '()))

(defun split-on-last-word-h (list word a)
  (cond ((null list) (list a '()))
	((and (equal (car list) word) (not (member word (cdr list)))) (list a (cdr list)))
	(t (split-on-last-word-h (cdr list) word (append a (list (car list)))))))

(defun split-on-first-word (list word)
  (split-on-first-word-h list word '()))

(defun split-on-first-word-h (list word a)
  (cond ((null list) (list a '()))
	((equal (car list) word) (list a (cdr list)))
	(t (split-on-first-word-h (cdr list) word (append a (list (car list)))))))

;; (A B C D E F D) --(D E)--> ((A B C) (D E F D))
;; (A B C E F D)   --(D E)--> ((A B C) (E F D))
(defun split-on-these-words (list words)
  (split-on-these-words-h list words '()))

(defun split-on-these-words-h (list words a)
  (cond ((null list) (list a '()))
	((my-member (car list) words) (list a (append (list (car list)) (cdr list))))
	(t (split-on-these-words-h (cdr list) words (append a (list (car list)))))))

;; (A B C D E F D) --(D E)--> ((A B C D E F) (D))
(defun split-on-last-of-these-words (list words)
  (split-on-last-of-these-words-h list words '()))

(defun split-on-last-of-these-words-h (list words a)
  (cond ((null list) (list a '()))
	((and (my-member (car list) words) (not (any-member words (cdr list))))
	 (list a (append (list (car list)) (cdr list))))
	(t (split-on-last-of-these-words-h (cdr list) words (append a (list (car list)))))))

;; (a b c 1 d e 2 f g h 4 i) (1 2 3 4) --> ((a b c) (d e) (f g h) () (i))
(defun split-on-all-these-words (list words)
  (split-on-all-these-words-h list words 0 (list-of-n-x '() (+ 1 (length words)))))

(defun split-on-all-these-words-h (list words n sofar)
  (cond
   ((null list) sofar)
   ((equal (car list) (car words))
    (split-on-all-these-words-h (cdr list) (cdr words) (+ n 1) sofar))
   ((my-member (car list) (cdr words))
    (split-on-all-these-words-h (cdr list) 
				(cdrn words (+ 1 (which-member (car list) words)))
				(+ n 1 (which-member (car list) words)) sofar))
   (t (split-on-all-these-words-h (cdr list) words n (append-nth-element (car list) n sofar)))))

;; inp: '(hello joe my name is blah bye now) 'my 'blah
;; out:  ((hello joe) (my name is blah) (bye now))
(defun split-on-sub-list (list sub-list-start sub-list-end)
  (split-on-sub-list-h list sub-list-start sub-list-end '(() () ())))

(defun split-on-sub-list-h (list sub-list-start sub-list-end so-far)
  (cond ((null list) so-far)
	;; still not found the sublist
	((null (cadr so-far))
	 (if (equal (car list) sub-list-start)
	     (split-on-sub-list-h (cdr list) 
				  sub-list-start 
				  sub-list-end 
				  (list (car so-far) (list sub-list-start) '()))
	   (split-on-sub-list-h (cdr list) 
				  sub-list-start 
				  sub-list-end 
				  (list (append (car so-far) (list (car list)))
					'()
					'()))))
	;; still have not found end of sublist
	((null (caddr so-far))
	 (if (equal (last-element (cadr so-far)) sub-list-end)
	     (split-on-sub-list-h (cdr list) 
				  sub-list-start 
				  sub-list-end 
				  (list (car so-far) (cadr so-far) (list (car list))))
	   (split-on-sub-list-h (cdr list) 
				sub-list-start 
				sub-list-end 
				(list (car so-far) 
				      (append (cadr so-far) (list (car list))) 
				      '()))))
	(t (split-on-sub-list-h (cdr list) 
				sub-list-start 
				sub-list-end 
				(list (car so-far) 
				      (cadr so-far) 
				      (append (caddr so-far) (list (car list))))))))

;; (a and b and c) 'and --> ((a) (b) (c))
(defun parse-on-word (exp word)
  (cond ((null exp) exp)
	((member word exp) 
	 (let ((split (split-on-first-word exp word))) 
	   (append (parse-on-word (car split) word) 
		   (parse-on-word (cadr split) word))))
	(t (list exp))))

;; ((a) (b) (c)) 'and --> (a and b and c)
;; (a b c) 'and --> (a and b and c)
(defun unparse-with-word (parsed-exp word)
  (cond ((null parsed-exp) '())
	((null (cdr parsed-exp)) (list (car parsed-exp)))
	(t (append (list (car parsed-exp)) 
		   (list word) 
		   (unparse-with-word (cdr parsed-exp) word)))))

;; (a b c) --> (a x b x c)
(defun insert-seperator (l s)
  (cond ((or (null l) (null (cdr l))) l)
	(t (append (list (car l) s) (insert-seperator (cdr l) s)))))	 	

;; (a (b c)) -> ((a) (b c))
(defun listify-atoms (list)
  (cond ((null list) '())
	((atom (car list)) (cons (list (car list)) (listify-atoms (cdr list))))
	(t (cons (car list) (listify-atoms (cdr list))))))

;; (1 2 3 4) (2 3) ("two" "three") --> (1 "two" "three" 4)
(defun replace-sub-list (list lold lnew)
  (cond ((null list) '())
	((is-prefix list lold)
	 (append lnew (cdrn list (length lold))))
	(t (cons (car list) (replace-sub-list (cdr list) lold lnew)))))

(defun is-prefix (big small)
  (cond ((and (null big) (null small)) t)
	((null big) '())
	((null small) t)	
	((equal (car big) (car small)) 
	 (is-prefix (cdr big) (cdr small)))
	(t '())))

(defun string-to-list (str)
   (do* ((stringstream (make-string-input-stream str))
         (result nil (cons next result))
         (next (read stringstream nil 'eos)
               (read stringstream nil 'eos)))
        ((equal next 'eos) (reverse result))))

(defun string-list-to-string (sl)
  (cond ((null sl) "")
	((null (cdr sl)) (car sl))
	(t (concatenate 'string (car sl) " " (string-list-to-string (cdr sl))))))

(defun string-to-pseudo-list (str)
  (cons 'pseudo-list (string-to-list str)))

(defun set-to-list (set)
  (reverse (cdr (reverse (cdr (string-to-list set))))))

(defun list-to-string (list)
  (cond ((null list) "")
	((null (cdr list)) (write-to-string (car list)))
	(t (concatenate 'string 
			(write-to-string (car list)) 
			" " 
			(list-to-string (cdr list))))))

(defun pseudo-list-to-string (list)
  (if (pseudo-listp list) (list-to-string (cdr list)) list))

(defun list-to-set (list)
  (concatenate 'string "{ " (list-to-string (remove-duplicates list)) " }"))

;; (a "b c" d "e") -> (a (b c) d (e))
(defun all-strings-to-pseudo-list (list)
  (cond ((null list) '())
	((stringp (car list)) (cons (string-to-pseudo-list (car list))
				    (all-strings-to-pseudo-list (cdr list))))
	((atom (car list)) (cons (car list) (all-strings-to-pseudo-list (cdr list))))
	(t (cons (all-strings-to-pseudo-list (car list)) 
		 (all-strings-to-pseudo-list (cdr list))))))

;; (a (b c) d (e)) -> (a "b c" d "e")
(defun all-pseudo-lists-to-string (list)
  (cond ((null list) '())
	((atom (car list)) (cons (car list) (all-pseudo-lists-to-string (cdr list))))
	((pseudo-listp (car list)) (cons (pseudo-list-to-string (car list))
					 (all-pseudo-lists-to-string (cdr list))))
	(t (cons (all-pseudo-lists-to-string (car list)) 
		 (all-pseudo-lists-to-string (cdr list))))))

(defun cars (items)
  (cond ((null items) '())
	(t (cons (car (car items))
		 (cars (cdr items))))))

;; a '((b c) (e f)) --> ((a b c) (a e f))
(defun conss (item list)
  (cond ((null list) '())
	(t (cons (cons item (car list)) (conss item (cdr list)))))) 

(defun reset-vars ()
  ;; the knowledge-base is called soracle
  (setq soracle '())
  (setq current-world '())
  ;; stores are instances of objects
  (setq instance-list '())
  (setq last-action-list '())
  (setq last-goal-list '())
  (setq global-opts '()))

;; soracle:      ( ( world1 ( ( object1 attributes1 ...) ... ) ) ...)
;;               ((nim (       )))  
;;               ((nim ((board (att1 att2) ((inst1) ...) ))))
;;
;; ((NIM
;;              ((PLAYER
;;                ((NAME OPPONENT TURN)
;;                 ((STATUS WON
;;                   (IS PLAYER TURN NO AND NIM-BOARD NUMBER-STONES 0)))
;;                 ((PLAYER2 PLAYER1 NO) (PLAYER1 PLAYER2 YES))))
;;               (BOARD ((NAME NUMBER-STONES) NIL ((NIM-BOARD 9)))))))

;; adds knowledge to soracle
(defun update-soracle (world object instance qualification action rule 
		       property-name-and-value rel-qualification subobjects 
		       nlp-phrase goal active-deactive-goal)
  (cond
   ;; ading a new rule (or its nlp verion) for an action of an object
   (rule 
    (let* ((is-nlp-rule (= 1 (car rule)))
	   (the-rule (cadr rule))
	   (world-object-knowledge (world-object-knowledge (world-knowledge world)))
	   (current-actions (remove-action action (action-knowledge object)))
	   (updated-action (if is-nlp-rule
			       (list action
				     (list 
				      (get-action-sol object action)
				      (list 
				       (action-nlp-var-knowledge object action)
				       (action-nlp-means-knowledge object action)
				       (cons 
					the-rule 
					(action-nlp-rule-knowledge object action))
				       (action-nlp-consequence-knowledge object action))))
				(list action 
				      (list (list 
					     (action-var-knowledge object action)
					     (cons 
					      the-rule 
					      (action-rule-knowledge object action))
					     (action-consequence-knowledge object action))
					    (get-action-nlp object action))))))
      (setq soracle 
	    (cons (list world
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object 
				    (list (subobject-knowledge object) 
					  (property-knowledge object)
					  (qualification-knowledge object)
					  (cons 
					   updated-action
					   current-actions)
					  (goal-knowledge object)
					  (instance-knowledge object)))
			      (remove-object object world-object-knowledge)))		
		  (remove-world world soracle)))))
   ;; ading a new action for an object
   (action 
    (let* ((is-nlp-action (= 1 (car action)))
	   (the-action (cadr action))
	   (world-object-knowledge (world-object-knowledge (world-knowledge world)))
	   (current-actions (if is-nlp-action 
			      (remove-object (car the-action) (action-knowledge object)) 
			    (action-knowledge object)))
	   (action-parsd (parse-action-def the-action object is-nlp-action)))
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list (subobject-knowledge object)
						 (property-knowledge object)
						 (qualification-knowledge object)
						 (cons 
						  action-parsd
						  current-actions)
						 (goal-knowledge object)
						 (instance-knowledge object)))
			      (remove-object object world-object-knowledge)))		
		  (remove-world world soracle)))))
   ;; ading a new goal (or nlp version of goal) for an object
   (goal 
    (let* ((is-nlp-goal (= 1 (car goal)))
	   (the-goal (cadr goal))
	   (world-object-knowledge (world-object-knowledge (world-knowledge world)))
	   (current-goals (if is-nlp-goal 
			      (remove-object (car the-goal) (goal-knowledge object)) 
			    (goal-knowledge object)))
	   (goal-parsd (parse-goal-def the-goal object is-nlp-goal)))
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list (subobject-knowledge object)
						 (property-knowledge object)
						 (qualification-knowledge object)
						 (action-knowledge object)
						 (cons 
						  goal-parsd
						  current-goals)
						 (instance-knowledge object)))
			      (remove-object object world-object-knowledge)))		
		  (remove-world world soracle)))))
   ;; activating a goal for an instance
   (active-deactive-goal 
    (let  ((world-object-knowledge (world-object-knowledge (world-knowledge world))))
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list 
					    (subobject-knowledge object) 
					    (property-knowledge object) 
					    (qualification-knowledge object) 
					    (action-knowledge object) 
					    (goal-knowledge object)
					    (cons
					     (list
					      instance
					      (list 
					       (get-instance-properties-wo-instance instance)
					       (if (car active-deactive-goal)
						   ;; activating a goal
						   (cons 
						    (cadr active-deactive-goal)
						    (get-instance-active-goals instance))
						 ;; deactivating a goal
						 (my-remove 
						  (cadr active-deactive-goal)
						  (get-instance-active-goals instance)))))
					     (remove-instance 
					      instance 
					      (instance-knowledge object)))))
			      (remove-object object world-object-knowledge)))
		  (remove-world world soracle)))))
   ;; defining subgroups of an object (grouping)
   (subobjects
    (let ((world-object-knowledge (world-object-knowledge (world-knowledge world))))
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list subobjects
						 (property-knowledge object)
						 (qualification-knowledge object)
						 (action-knowledge object)
						 (goal-knowledge object)
						 (instance-knowledge object)))
			      (remove-object object world-object-knowledge)))		
		  (remove-world world soracle)))))
       ;; adding a new qualificatin for an object
   (qualification
    (let* ((world-object-knowledge (world-object-knowledge (world-knowledge world)))
	   (qualification-parsed (split-on-last-word qualification 'is))
	   (qualification-name (caar qualification-parsed))
	   (qualification-value (cdar qualification-parsed))
	   (qualification-pred (cadr qualification-parsed)))	   
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list (subobject-knowledge object) 
						 (property-knowledge object) 
						 (cons 
						  (list qualification-name
							(list 
							 qualification-value
							 qualification-pred))
						  (qualification-knowledge object))
						  (action-knowledge object)
						  (goal-knowledge object)
						 (instance-knowledge object)))
			      (remove-object object world-object-knowledge)))		
		  (remove-world world soracle)))))
   ;; updating a property of an instance of an object
   (property-name-and-value 
    (let* ((world-object-knowledge (world-object-knowledge (world-knowledge world)))
	   (property (car property-name-and-value))
	   (property-value (cadr property-name-and-value))
	   (instance-properties-updated (key-list-val-list-update
					 property
					 property-value
					 (property-knowledge object)
					 (get-instance-properties instance))))
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list (subobject-knowledge object) 
						 (property-knowledge object) 
						 (qualification-knowledge object) 
						 (action-knowledge object) 
						 (goal-knowledge object)
						 (cons
						  (list
						   (car instance-properties-updated)
						   (list (cdr instance-properties-updated)
							 (get-instance-active-goals instance)))
						  (remove-instance 
						   instance 
						   (instance-knowledge object)))))
			      (remove-object object world-object-knowledge)))
		  (remove-world world soracle)))))
   ;; adding a new instance of an object
   (instance 
    (let ((world-object-knowledge (world-object-knowledge (world-knowledge world))))
      (setq soracle 
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons (list object (list (subobject-knowledge object)
						 (property-knowledge object) 
						 (qualification-knowledge object) 
						 (action-knowledge object) 
						 (goal-knowledge object)
						 (cons instance (instance-knowledge object))))
			      (remove-object object world-object-knowledge)))
		  (remove-world world soracle)))
      (add-instance-list current-world object (car instance))))
   ;; adding a new relative qualification between two (maybe same) objects
   (rel-qualification 
    (let ((world-object-knowledge (world-object-knowledge (world-of-soracle world soracle))))
      (setq soracle
	    (cons (list world 
			(cons 
			 (list (cadr rel-qualification)
			       (list (car rel-qualification)
				     (caddr rel-qualification)
				     (cddddr rel-qualification)))
			 (world-rel-qualification-knowledge world))
			(world-nlp-knowledge world)
			world-object-knowledge)
		  (remove-world world soracle)))))
   ;; adding a new english nlp phrase
   (nlp-phrase
    (let* ((world-object-knowledge (world-object-knowledge (world-of-soracle world soracle)))
	   (means-split (split-on-first-word nlp-phrase 'means))
	   (respond-split (split-on-first-word (cadr means-split) 'respond))
	   (nlp-phrase-english-inp (car means-split))
	   (nlp-phrase-sol-meaning (car respond-split))
	   (nlp-phrase-english-out (cdadr respond-split))
	   (nlp-phrase-vars (extract-nlp-inp-vars nlp-phrase-english-inp 
						  nlp-phrase-sol-meaning)))
      (setq soracle
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(cons 
			 (list nlp-phrase-english-inp
			       (list nlp-phrase-vars
				     nlp-phrase-sol-meaning
				     nlp-phrase-english-out)) 
			 (world-nlp-knowledge world))
			world-object-knowledge)
		  (remove-world world soracle)))))
   ;; adding a new object in a world   
   (object 
    (let ((world-object-knowledge (world-object-knowledge (world-of-soracle world soracle))))
      (setq soracle
	    (cons (list world 
			(world-rel-qualification-knowledge world)
			(world-nlp-knowledge world)
			(cons object world-object-knowledge))
		       (remove-world world soracle)))))
   ;; adding a new world: (world (nlp) (rel-qualifications) (objects))
   (t (setq soracle (cons (list world '() '() '()) soracle))
      (update-current-world world))))

(defun update-current-world (world)
  (setq current-world world))

;; extract a certain object knowledge from a world object knowledge
(defun object-of-world (object world)
  (cond ((null world) '())
	((equal (caar world) object)
	 (cadar world))
	(t (object-of-world object (cdr world)))))

;; extract a certain world knowledge from soracle
(defun world-of-soracle (world tmp-soracle)
  (cond ((null tmp-soracle) '())
	((equal (caar tmp-soracle) world)
	 (cdar tmp-soracle))
	(t (world-of-soracle world (cdr tmp-soracle)))))

;; remove a certain world knowledge from soracle
(defun remove-world (world tmp-soracle)
  (cond ((null tmp-soracle) '())
	((equal (caar tmp-soracle) world) (remove-world world (cdr tmp-soracle)))
	(t (cons (car tmp-soracle) (remove-world world (cdr tmp-soracle))))))

;; remove a certain object knowledge from a world
(defun remove-object (object world)
  (cond ((null world) '())
	((equal (caar world) object) (remove-object object (cdr world)))
	(t (cons (car world) (remove-object object (cdr world))))))

;; remove a certain instance knowledge from an object
(defun remove-instance (instance instance-knowledge)
  (cond ((null instance-knowledge) '())
	((equal (caar instance-knowledge) instance) 
	 (remove-instance instance (cdr instance-knowledge)))
	(t (cons (car instance-knowledge) 
		 (remove-instance instance (cdr instance-knowledge))))))

;; remove a certain action knowledge from an object
(defun remove-action (action action-knowledge)
  (cond ((null action-knowledge) '())
	((equal (caar action-knowledge) action) (remove-action action (cdr action-knowledge)))
	(t (cons (car action-knowledge) (remove-action action (cdr action-knowledge))))))

;; part of soracle about a world
(defun world-knowledge (world)
   (world-of-soracle world soracle))

;; part of soracle about an object in world
(defun object-knowledge (object)
  (let* ((world-knowledge (world-of-soracle current-world soracle))
	 (object-knowledge (object-of-world object (world-object-knowledge world-knowledge))))
    object-knowledge))

;; part of soracle about instances of an object in a world
(defun instance-knowledge (object)
  (cadddr (cddr (object-knowledge object))))

(defun action-knowledge (object)
  (cadddr (object-knowledge object)))

(defun goal-knowledge (object)
  (cadddr (cdr (object-knowledge object))))

(defun action-var-knowledge (object action)
  (car (get-action-sol object action)))

(defun action-rule-knowledge (object action)
  (cadr (get-action-sol object action)))

(defun action-consequence-knowledge (object action)
  (caddr (get-action-sol object action)))

(defun action-nlp-var-knowledge (object action)
  (car (get-action-nlp object action)))

(defun action-nlp-means-knowledge (object action)
  (cadr (get-action-nlp object action)))

(defun action-nlp-rule-knowledge (object action)
  (caddr (get-action-nlp object action)))

(defun action-nlp-consequence-knowledge (object action)
  (cadddr (get-action-nlp object action)))

(defun goal-var-knowledge (object goal)
  (car (get-goal-sol object goal)))

(defun goal-when-knowledge (object goal)
  (cadr (get-goal-sol object goal)))

(defun goal-requires-knowledge (object goal)
  (caddr (get-goal-sol object goal)))

(defun goal-try-knowledge (object goal)
  (cadddr (get-goal-sol object goal)))

(defun goal-consequence-knowledge (object goal)
  (cadddr (cdr (get-goal-sol object goal))))

(defun goal-nlp-var-knowledge (object goal)
  (car (get-goal-nlp object goal)))

(defun goal-nlp-means-knowledge (object goal)
  (cadr (get-goal-nlp object goal)))

(defun goal-nlp-when-knowledge (object goal)
  (caddr (get-goal-nlp object goal)))

(defun goal-nlp-requires-knowledge (object goal)
  (cadddr (get-goal-nlp object goal)))

(defun goal-nlp-try-knowledge (object goal)
  (cadddr (cdr (get-goal-nlp object goal))))

(defun goal-nlp-consequence-knowledge (object goal)
  (cadddr (cddr (get-goal-nlp object goal))))

(defun qualification-knowledge (object)
  (caddr (object-knowledge object)))

(defun world-rel-qualification-knowledge (world)
  (car (world-knowledge world)))

(defun world-nlp-knowledge (world)
  (cadr (world-knowledge world)))

(defun world-object-knowledge (world-knowledge)
  (caddr world-knowledge))

(defun subobject-knowledge (object)
  (car (object-knowledge object)))

(defun property-knowledge (object)
  (cadr (object-knowledge object)))

;; (player1 as-happy-as player2) -> (player1 status = player2 status)
(defun rel-qualification-to-direct-pred (rel-qualification-pred)
  (let* ((rel-qualification-knowledge 
	  (get-rel-qualification current-world (cadr rel-qualification-pred)))
	 (rel-qualification-instances (list (car rel-qualification-pred)
					    (caddr rel-qualification-pred)))
	 (rel-qualification-objects (list (car rel-qualification-knowledge)
					  (cadr rel-qualification-knowledge)))
	 (rel-qualification-direct-pred (caddr rel-qualification-knowledge)))
    (plug-in-bindings-values rel-qualification-objects 
			     rel-qualification-instances
			     rel-qualification-direct-pred)))

(defun qualification-name (qualification)
  (car qualification))

(defun qualification-value (qualification)
  (cadr qualification))

(defun qualification-pred (qualification)
  (caddr qualification))

(defun list-worlds ()
  (cars soracle))

(defun list-objects (world)
  (cars (world-object-knowledge (world-knowledge world))))

(defun list-rel-qualifications (world)
  (cars (world-rel-qualification-knowledge world)))

(defun list-nlps (world)
  (cars (world-nlp-knowledge world)))

(defun nlp-respond (cmd nlp-inp nlp-vars nlp-var-vals)
  (let* ((instances (extract-instances cmd))
         (objects (extract-objects nlp-inp))
	 (nlp-sol-trans-and-vars-and-nlp-out (nlp-lookup nlp-inp))	 
	 (other-nlp-vars (extract-nlp-inp-vars nlp-inp 
					       (car nlp-sol-trans-and-vars-and-nlp-out)))
	 (other-nlp-var-vals (extract-nlp-inp-var-vals nlp-vars nlp-inp cmd))	 
	 (nlp-sol-trans (plug-in-bindings-values (append objects other-nlp-vars nlp-vars)
						 (append instances other-nlp-var-vals 
							 nlp-var-vals)
						 (cadr nlp-sol-trans-and-vars-and-nlp-out)))
	 (nlp-out (caddr nlp-sol-trans-and-vars-and-nlp-out))
	 (ans (eval-exp nlp-sol-trans)))
    ;; if it is an action, goal, or info we need to call run-cmd, since its a sideeffect
    (if (or (equal (car nlp-sol-trans) 'is)
	    (is-action-cmd nlp-sol-trans) 
	    (is-undo-cmd 'action nlp-sol-trans)
	    (is-undo-cmd 'goal nlp-sol-trans)
	    (is-goal-cmd nlp-sol-trans) 
	    (is-goal-explain nlp-sol-trans) 
	    (is-action-subgoal-intent-explain nlp-sol-trans)
	    (is-info-cmd nlp-sol-trans))
	(run-cmd nlp-sol-trans)
      ;; otherwise just call eval-exp to get return value      
      (cond ((and nlp-out (setp ans))  
	     (list 0 (list-to-string (flatten (plug-in-bindings-values 
					       (cons 'answer objects) 
					       (cons (nlp-set-to-english ans) instances)
					       nlp-out)))))
	    (nlp-out (list 0 (list-to-string (plug-in-bindings-values (cons 'answer objects) 
								      (cons ans instances) 
								      nlp-out))))
	    (t (list 0 (list-to-string ans)))))))

(defun nlp-lookup (nlp-inp)
  (hash-lookup nlp-inp (world-nlp-knowledge current-world)))

(defun nlp-set-to-english (set)
  (unparse-with-word (set-to-list set) 'and))

(defun any-nlps (world)
  (not (null (world-nlp-knowledge world))))

(defun is-nlp-cmd (cmd)
  (and (any-nlps current-world)
       (let ((untrns (untranslate-instances-into-objects cmd)))
	 (is-nlp-cmd-h untrns (list-nlps current-world)))))

(defun is-nlp-cmd-h (poss-untranslations all-nlp-phrases)
  (cond ((null poss-untranslations) '())
	(t (let ((next (examine-cmd-for-nlp (car poss-untranslations)
					    all-nlp-phrases)))
	     (if next next (is-nlp-cmd-h (cdr poss-untranslations)
					 all-nlp-phrases))))))

(defun examine-cmd-for-nlp (cmd nlps)
  (cond ((null nlps) '())
	(t (let* ((nlp-sol-trans-and-vars-and-nlp-out (nlp-lookup (car nlps)))
		  (nlp-vars (car nlp-sol-trans-and-vars-and-nlp-out))
		  (match-try (wild-card-match (car nlps) cmd nlp-vars)))
	     (if (car match-try)
		 (list (car nlps) (cadr match-try) (caddr match-try))
	       (examine-cmd-for-nlp cmd (cdr nlps)))))))
	

(defun is-info-cmd (cmd)
  (and (eq (car cmd) 'info) 
       (member '= (cdr cmd))
       (knownp (eval-exp (but-last (cadr (split-on-sub-list cmd (cadr cmd) '=)))))))

(defun list-qualifications (object)
  (cars (qualification-knowledge object)))

(defun is-object (object)
  (member object (list-objects current-world)))

(defun is-rel-qualification (rel-qualification)
  (member rel-qualification (list-rel-qualification current-world)))

(defun is-qualification (object qualification)
  (member qualification (list-qualifications object)))

(defun is-property (object property)
  (member property (property-knowledge object)))

(defun is-action (object action)
  (if (member action (cars (action-knowledge object)))
      object
    (is-action-h (object-groups object) action)))

(defun is-action-h (objects action)
  (cond ((null objects) '())
	((member action (cars (action-knowledge (car objects))))
	 (car objects))
	(t (is-action-h (cdr objects) action))))

(defun is-goal (object goal)
  (if (member goal (cars (goal-knowledge object)))
      object
    (is-goal-h (object-groups object) goal)))

(defun is-goal-h (objects goal)
  (cond ((null objects) '())
	((member goal (cars (goal-knowledge (car objects))))
	 (car objects))
	(t (is-goal-h (cdr objects) goal))))

(defun is-want-exp (pred object)
  (and (not (null pred)) (not (null (cdr pred))) (not (null (cddr pred)))
       (equal (car pred) 'want) (equal object (cadr pred))))

(defun goal-of-want (want-exp)
  (cddr want-exp))

(defun is-action-cmd (cmd)
  (let ((1st (car cmd)) (2nd (cadr cmd)))
    (or (and (is-instance 1st)
	     (is-action (instance-object 1st) 2nd)))))	

(defun is-goal-cmd (cmd)
  (let ((1st (car cmd)) (2nd (cadr cmd)))
    (or (and (is-instance 1st)
	     (is-goal (instance-object 1st) 2nd)))))

(defun is-undo-cmd (action-or-goal cmd)
  (let ((1st (car cmd)) (2nd (cadr cmd)) (3rd (caddr cmd)) 
	(action-undo (equal action-or-goal 'action)))
	(and (is-instance 1st)
	     (eq 'undo 2nd)
	     (or (and action-undo (is-action (instance-object 1st) 3rd))
		 (and (not action-undo) (is-goal (instance-object 1st) 3rd))))))

(defun is-action-explain (cmd)
  (and (<= 5 (length cmd)) 
       (let ((1st (car cmd)) (2nd (cadr cmd)) (3rd (caddr cmd)) 
	     (4th (cadddr cmd)) (5th (cadddr (cdr cmd))))
	 (and (equal 'explain 1st)
	      (equal 'how 2nd)
	      (equal 'can 3rd)
	      (is-instance 4th)
	      (is-action (instance-object 4th) 5th)))))

(defun is-action-subgoal-intent-explain (cmd)
  (and (<= 5 (length cmd)) 
       (let ((1st (car cmd)) (2nd (cadr cmd)) (3rd (caddr cmd)) 
	     (4th (cadddr cmd)) (5th (cadddr (cdr cmd))))
	 (and (equal 'explain 1st)
	      (equal 'why 2nd)
	      (equal 'want 3rd)
	      (is-instance 4th)
	      (or (is-action (instance-object 4th) 5th)
		  (is-goal (instance-object 4th) 5th))))))

(defun explain-action-subgoal-intent (3rd-on)
  (let* ((instance (cadr 3rd-on))
	 (object (or (is-action (instance-object instance) (caddr 3rd-on)) 
		     (is-goal (instance-object instance) (caddr 3rd-on))))
	 (action-subgoal-cmd (cddr 3rd-on))
	 (action-subgoal (caddr 3rd-on))
	 (res (explain-action-subgoal-intent-h instance object action-subgoal-cmd 
					       (list-active-goals instance))))
    (if res
	(intent-list-to-nlp-paragraph res object instance)
      '())))

(defun explain-action-subgoal-intent-h (instance object action-subgoal-cmd active-goals)
  (cond ((null active-goals) '())
	(t (let* ((the-goal (car active-goals))
		  (goal-explain (explain-goal instance (car the-goal) (cdr the-goal) 
					      (list-active-goals instance) '() t))
		  (explain-res (cadr goal-explain)))
	     (if (= 0 explain-res)
		 (let ((find-intent (find-parent-goals action-subgoal-cmd 
						       (caddr goal-explain))))
		   (if find-intent (cons the-goal find-intent)
		     (explain-action-subgoal-intent-h instance object action-subgoal-cmd 
						      (cdr active-goals))))
	       (explain-action-subgoal-intent-h instance object action-subgoal-cmd 
						(cdr active-goals)))))))

(defun find-parent-goals (sub-goal goal-list)
  (find-parent-goals-h sub-goal goal-list))

(defun find-parent-goals-h (sub-goal goal-list)
  (cond ((or (null goal-list) (atom (car goal-list))) '())
	((equal (caar goal-list) pre-satisfied) 
	 (find-parent-goals-h sub-goal (cdr goal-list)))
	((and (atom (caar goal-list)) (null (cddr goal-list)))
	 (if (equal (car goal-list) sub-goal)
	     (list sub-goal)
	   (let ((inside (find-parent-goals-h sub-goal (cadr goal-list))))
	     (if inside 
		 (append (list (car goal-list)) inside)
	       '()))))
	(t (let ((1st (find-parent-goals-h sub-goal (car goal-list))))
	     (if 1st 1st
	       (find-parent-goals-h sub-goal (cdr goal-list)))))))

(defun is-goal-explain (cmd)
  (and (<= 5 (length cmd)) 
       (let ((1st (car cmd)) (2nd (cadr cmd)) (3rd (caddr cmd)) 
	     (4th (cadddr cmd)) (5th (cadddr (cdr cmd))))
	 (and (equal 'explain 1st)
	      (equal 'how 2nd)
	      (equal 'can 3rd)
	      (is-instance 4th)
	      (is-goal (instance-object 4th) 5th)))))

(defun is-qualification-explain (cmd)
  (and (<= 7 (length cmd)) 
       (let ((1st (car cmd)) (2nd (cadr cmd)) (3rd (caddr cmd)) 
	     (4th (cadddr cmd)) (5th (cadddr (cdr cmd)))
	     (6th (cadddr (cddr cmd))) (7th (cadddr (cdddr cmd))))
	 (and (equal 'explain 1st)
	      (equal 'why 2nd)
	      (equal 'is 3rd)
	      (or 
	       (and (is-instance 4th) ;; explain why is
		    (is-qualification (instance-object 4th) 5th)
		    0)
	       (and (equal 'not 4th)  ;; explain why is not
		    (is-instance 5th)
		    (is-qualification (instance-object 5th) 6th)
		    1))))))

(defun is-rel-qualification-explain (cmd)
    (and (<= 5 (length cmd)) 
       (let ((1st (car cmd)) (2nd (cadr cmd)) (3rd (caddr cmd)) (4th (cadddr cmd)))
	 (and (equal 'explain 1st)
	      (equal 'why 2nd)
	      (equal 'is 3rd)
	      (let ((clause (if (equal 'not 4th) (cddddr cmd) (cdddr cmd))))
		(and (not (any-member math-comps clause))
		     (any-member clause (list-rel-qualifications current-world))))))))

(defun explain-qualification (object qualification instance)
  (eval-multi-value-qualification object qualification instance))


(defun explain-not-qualification (object qualification-name qualification-value instance)  
  (explain-not-qualification-h object qualification-name qualification-value instance
			       (get-multi-value-qualification object qualification-name)))

(defun explain-not-qualification-h (object qualification-name qualification-value
						instance multi-value-qual)
  (cond ((null multi-value-qual) '())
	 ((equal qualification-value (caaar multi-value-qual))
	  (let* ((qualification-value-and-pred (car multi-value-qual))
		 (qualification-value (car qualification-value-and-pred))
		 (qualification-pred (cadr qualification-value-and-pred))
		 (qualification-pred-translated 
		  (if qualification-pred (my-replace-with-exceptions 
					  qualification-pred 
					  object 
					  instance
					  all-quantifiers)
		    '()))
		 (qualification-pred-evald 
		  (if qualification-pred 
		      (eval-pred-with-reason qualification-pred-translated) 
		    t)))
	    qualification-pred-evald))
	 (t (explain-not-qualification-h 
	     object 
	     qualification-name qualification-value
	     instance (cdr multi-value-qual)))))

(defun explain-rel-qualification (clause)
  (let* ((rel-qualification-name 
	  (any-member clause (list-rel-qualifications current-world)))
	 (rel-qualification-clause-left-and-right 
	  (split-on-first-word clause rel-qualification-name))
	 (rel-qualification-translated 
	  (rel-qualification-to-direct-pred 
	   (list (eval-exp (car rel-qualification-clause-left-and-right))
		 rel-qualification-name
		 (eval-exp (cadr rel-qualification-clause-left-and-right))))))
    (eval-pred-with-reason rel-qualification-translated)))

(defun list-instances (world object)
  (let ((subobjects (subobject-knowledge object)))
    (if subobjects
	(append (cars (instance-knowledge object)) 
		(list-subobject-instances world subobjects))
      (cars (instance-knowledge object)))))

(defun list-subobject-instances (world subobjects)
  (cond ((null subobjects) '())
	(t (append (list-instances world (car subobjects)) 
		   (list-subobject-instances world (cdr subobjects))))))

(defun list-active-goals (instance)
  (get-instance-active-goals instance))

(defun is-active-goal (object instance goal)
  (my-member-with-wild-card goal (list-active-goals instance)))

(defun run-action (instance action params just-explain)
  (let* ((object (is-action (instance-object instance) action))
	 (action-vars (action-var-knowledge object action))
	 (action-var-values (var-to-val-map action-vars params))
	 (rules-to-check 
	  (if (not (action-rule-knowledge object action))
	      '()
	    (plug-in-bindings-values
	     ;; bound object name to instance name, since its not in
	     ;; actions-vars
	     (cons object action-vars)
	     (cons instance action-var-values)
	     (unparse-with-word 
	      (action-rule-knowledge object action) 'and))))
	 (rules-checked  (if (not rules-to-check)
			     '(t)
			   (eval-pred-with-nlp-reason rules-to-check object instance action
						      (cons object action-vars) 
						      (cons instance action-var-values)))))
    ;; run any action rules first 
    ;; any rules passed
    (if (equal (car rules-checked) t)
	(let ((assignments (plug-in-bindings-values-multi-exp
			    (cons object action-vars)
			    (cons instance action-var-values)
			    (action-consequence-knowledge object action))))
	  (or just-explain
	      (and 
	       ;; record old property values for action undo
	       (reset-action-list-updates-knowledge instance action)
	       ;; update properties with new values 
	       (update-property-multi-times assignments instance action)))
	  (list t '()))
      (list '() (cadr rules-checked)))))

(defun explain-goal (instance goal params orig-goals just-explain no-nlp)
  (reset-goal-list-updates-knowledge instance)
  (let* ((goal-cmd (cons goal params))
	 (goal-run (run-goal instance goal params orig-goals just-explain no-nlp))
	 (run-res (cadr goal-run)))
    (if (= run-res 0)
	;; undo the succeeded goal, and reactivate it!      
	(goal-undo instance goal))
    goal-run))

(defun run-goal (instance goal params orig-goals just-explain no-nlp)
  (let* ((object (is-goal (instance-object instance) goal))
	 (goal-full (cons goal params))
	 (goal-vars (goal-var-knowledge object goal))
	 (goal-var-values (var-to-val-map goal-vars params)))
    ;(activate-goal instance goal-full) ;; fixme - hack!
	   ;; instance does not have such active goal:
    (cond ((not (is-active-goal object instance goal-full));; fixme: should commented out?
	   (list '() 3 (list (list-to-string (car (try-to-nlp-ize-goal-action-list goal 
							(list '(fixme))
							object instance
							goal-vars
							goal-var-values no-nlp))))))
	  ;; check is goal is pre-satisified (when pred isnt true), or we need to try run it
	  (t (let* ((when-pred-to-check
		     ;; run any goal preconditions first 
		     (if (not (goal-when-knowledge object goal))
			 '()
		       (plug-in-bindings-values
			;; bound object name to instance name, since its not in
			;; goals-vars
			(cons object goal-vars)
			(cons instance goal-var-values)
			(goal-when-knowledge object goal))))
		    (when-pred-checked
		     (if (not when-pred-to-check)
			 '(t)
		       (eval-pred-with-reason when-pred-to-check))))
	       (if (null (car when-pred-checked))
		   ;; want pred is not true, this goal is pre-satisified, no need to run:
		   (list t 4 (caddr when-pred-checked))
		   ;; we need to try this goal:		   	      
		 (let* ((rules-to-check 
			 ;; run any goal preconditions first 
			 (if (not (goal-requires-knowledge object goal))
			     '()
			   (plug-in-bindings-values
			    ;; bound object name to instance name, since its not in
			    ;; goals-vars
			    (cons object goal-vars)
			    (cons instance goal-var-values)
			    (goal-requires-knowledge object goal))))
			(rules-checked  
			 (if (not rules-to-check)
			     '(t)
			   (eval-pred-with-nlp-reason rules-to-check object instance goal
						      (cons object goal-vars)
						      (cons instance goal-var-values)))))
		   (if (equal (car rules-checked) t)
		       ;; any preconditions passed. see if any "try"s possible, if so run it
		       (let ((trys-tried (run-goal-trys object instance 
							goal goal-vars goal-var-values 
							orig-goals
							just-explain no-nlp)))
			 (if (car trys-tried)
			     ;; some "try" was sucessful, now do goal consequences:
			     (let ((assignments (plug-in-bindings-values-multi-exp
						 (cons object goal-vars)
						 (cons instance goal-var-values)
						 (goal-consequence-knowledge object goal))))
			       (or just-explain
				   (and 
				    ;; update poperties with new values 
				    (update-property-multi-times assignments instance goal)
				    ;; goal is satisfied, now deactivate it:
				    (if (not (my-member goal-full orig-goals))
					(deactivate-goal instance goal-full))))
			       (list t 0 (cadr trys-tried)))
			   ;; all trys failed:
			   (list '() 1 (cadr trys-tried))))
		     ;; some precondition failes, goal is not runnable:
		     (list '() 2 (cadr rules-checked))))))))))

;; 0: added 1: already active 2: fail
(defun activate-goal (instance goal)
  (let ((object (instance-object instance)))
    (if (is-goal object (car goal))
	(if (not (is-active-goal object instance goal))
	    (let ((x 1))
	      (update-soracle current-world object instance 
			      '() '() '() '() '() '() '() '() (list t goal)) 0)
	  1)
      2)))

;; 0: removed 1: was not active 2: fail
(defun deactivate-goal (instance goal)
  (let ((object (instance-object instance)))
    (if (is-goal object (car goal))
	(if (is-active-goal object instance goal)
	    (let ((x 1))
	      (update-soracle current-world object instance 
			      '() '() '() '() '() '() '() '() (list '() goal)) 0)
	  1)
      2)))

;; auto-activate goals if qualified
;; since can have chain reaction, has to keep calling 
;; helper fn  until no more activation possible
(defun activate-qualified-goals (instance)
  (let* ((object (instance-object instance))
         (1st-round (activate-qualified-goals-h object instance (goal-knowledge object))))
    1st-round))
;; FIXME:: commented lines below, b/c maybe sub-goals should not be auto-activated here!
;;         (they're activated when parent goal is run)
;    (if 1st-round 
;	(append 1st-round 
;		(activate-qualified-goals-h object instance (goal-knowledge object)))
;      '())))
  
(defun activate-qualified-goals-h (object instance all-goals)
  (cond ((null all-goals) '())
	(t (let ((goal (caar all-goals))
		 (rest (activate-qualified-goals-h object instance (cdr all-goals))))
	     ;; only can auto-activate goals w/o vars!
	     (if (goal-var-knowledge object goal)
		 rest
	       (let* ((when-exp (goal-when-knowledge object goal))
		      (goal-checked (check-and-activate-goal when-exp object instance goal)))
		 (if goal-checked 
		     (cons (list goal) rest)
		   rest)))))))

;; when-exp could either be another goal (want..) or a direct predicate
(defun check-and-activate-goal (when-exp object instance goal)
  (let ((a-want (is-want-exp when-exp object)))
    (if (and (not (is-active-goal object instance (list goal)))
	     (or (and '() ;; FIXME: commented this and out b/c 
		          ;;        maybe subgoals shouldnt be auto-activated
		      a-want
		      (not (equal goal (car (goal-of-want when-exp))))
		      (is-active-goal object instance (goal-of-want when-exp)))
		 (and (not a-want)
		      (let ((rules-to-check 		     
			     (plug-in-bindings-values
			      (list object)
			      (list instance)
			      when-exp)))
			(eval-pred rules-to-check)))))
	;; this goal should be activated
	(= 0 (activate-goal instance (list goal)))
      '())))

;; runs and/ors of trys assoicated with a goal, returns false if fail,
;; the fn is log-or by default, since it is a sucess on first try cmd succeeding,
;; if log-and-or argument is 'or it makes it a logical or operation. 
;; if log-and-or argument is 'and it makes it a logical and operation. 
;; if log-and-or argument is 'orand it makes it a logical or, but all failed trys
;; previous to succeeded try will be included as part of whole parent try
(defun run-goal-trys (object instance goal goal-vars goal-var-values 
			                   orig-goals just-explain no-nlp)
  (let* ((goal-trys (goal-try-knowledge object goal))
	 (goal-trys-trans
	  (plug-in-bindings-values-multi-exp
	   (cons object goal-vars)
	   (cons instance goal-var-values)
	   goal-trys))
	 (has-any-keyword (my-member 'any goal-trys-trans))
	 (goal-trys-final1 (translate-for-x-exps goal-trys-trans 'any))
	 (has-any-keyword (not (equal goal-trys-final1 goal-trys-trans)))
	 (goal-trys-final2 (if has-any-keyword 
			       goal-trys-final1
			     (translate-for-x-exps goal-trys-trans 'all)))
	 (has-all-keyword (not (equal goal-trys-final2 goal-trys-trans)))
	 (goal-trys-final (or (and has-any-keyword goal-trys-final1) 
			      (and has-all-keyword goal-trys-final2)
			      goal-trys))
	 ;; for any cases: all failed trys prior to succeeded one are part of suceeded try
	 (log-and-or (cond (has-any-keyword 'andor)  (has-all-keyword 'and) (t 'or))))
    (run-goal-trys-h object instance goal goal-vars goal-var-values 
		     goal-trys-final orig-goals 
		     log-and-or just-explain no-nlp)))

(defun run-goal-trys-h (object instance goal goal-vars 
			goal-var-values trys orig-goals log-and-or just-explain no-nlp)  
  (cond ((null trys) (list '() '()))
	(t (let* ((and-case (equal log-and-or 'and))
		  (or-case (and (not and-case) (equal log-and-or 'or)))
		  (and-or-case (and (or (not and-case) (not or-case)) (equal log-and-or 'andor)))
		  (full-try (car trys)))	     
	     ;; if this is a and of multi trys all have to pass:
	     (if (my-member 'and full-try)
		 (let ((combo-try-evald 
			(run-goal-trys-h object instance goal goal-vars 
					 goal-var-values (parse-on-word full-try 'and) 
					 orig-goals 'and just-explain no-nlp)))
		   (if (or (car combo-try-evald)
			   (null (cdr trys)))
			   combo-try-evald
		     (let ((rest-evald
			    (run-goal-trys-h object instance goal 
					     goal-vars goal-var-values (cdr trys) 
					     orig-goals log-and-or just-explain no-nlp)))
		       (if and-or-case 
			   (if (car rest-evald)
			       (list t (append (plug-in-bindings-values-multi-exp
						(cons object goal-vars)
						(cons instance goal-var-values)
						(parse-on-word full-try 'and))
					       (cadr rest-evald)))
			     (list '() (cdr rest-evald)))
			 rest-evald))))
	       ;; if this is a single try:
	       (let* ((try-parsed (split-on-first-word full-try 'is))
		      (try (car try-parsed))
		      (try-pred (cadr try-parsed))
		      (try-goal-or-action (cadr try))
		      (try-goal-or-action-params (cddr try))
		      (try-goal-or-action-vars 
		       (if (is-action object try-goal-or-action)
			   (action-var-knowledge object try-goal-or-action)
			 (goal-var-knowledge object try-goal-or-action)))
		      (params-translated (plug-in-bindings-values
					  (cons object goal-vars)
					  (cons instance goal-var-values)
					  try-goal-or-action-params))
		      (try-goal-or-action-params-translated 
		       (if try-goal-or-action-params 
			   ;; if #vars != #vals, probably some multi word value present
			   (if (= (length try-goal-or-action-vars) 
				  (length try-goal-or-action-params))
			       params-translated
			     (list (eval-exp params-translated)))
			 '()))
		      (try-cmd (cons try-goal-or-action 
				     try-goal-or-action-params-translated))
		      (try-pred-evald
		       (if try-pred
			   (eval-pred 
			    (plug-in-bindings-values
			     (cons object goal-vars)
			     (cons instance goal-var-values)
			     try-pred))
			 t)))
		 ;; if this try has a predicate, we only run try if pred is met:
		 (if (not try-pred-evald) 
		     ;; no need to exec this try
		     (if and-case
			 (if (null (cdr trys))
			     (list t (list (cons pre-satisfied 
						 (car (try-to-nlp-ize-goal-action-list
						       '()
						       (list try-cmd)
						       object instance
						       try-goal-or-action-vars 
						       try-goal-or-action-params-translated
						       no-nlp)))))
			   (let ((rest-evald 
				  (run-goal-trys-h 
				   object instance goal 
				   goal-vars goal-var-values (cdr trys) 
				   orig-goals log-and-or just-explain no-nlp)))
			     (if (car rest-evald)
				 (list t (cons (cons pre-satisfied 
						     (car (try-to-nlp-ize-goal-action-list
							   '()
						       (list try-cmd)
						       object instance
						       try-goal-or-action-vars 
						       try-goal-or-action-params-translated
						       no-nlp)))
					       (cadr rest-evald)))
			       (list '() (cdr rest-evald)))))
		       (list t (list (cons pre-satisfied 
					   (car (try-to-nlp-ize-goal-action-list
						 '()
						 (list try-cmd)
						 object instance
						 try-goal-or-action-vars 
						 try-goal-or-action-params-translated
						 no-nlp))))))
		   ;; no predicates for this try or they passed, so run them:
		   ;; this try is an action to run
		   (cond ((is-action object try-goal-or-action)
			  (let ((action-run 
				 (run-action instance try-goal-or-action 
					     try-goal-or-action-params-translated
					     just-explain)))
			    ;; action succeeded
			    (if (car action-run)
				(if and-case
				    (if (null (cdr trys))
					(list t (try-to-nlp-ize-goal-action-list
						 '()
						 (list try-cmd)
						 object instance
						 try-goal-or-action-vars 
						 try-goal-or-action-params-translated
						 no-nlp))
				      (let ((rest-evald 
					     (run-goal-trys-h 
					      object instance goal 
					      goal-vars goal-var-values (cdr trys) 
					      orig-goals log-and-or just-explain no-nlp)))
					(if (car rest-evald)
					    (list t (cons (car (try-to-nlp-ize-goal-action-list
								'()
								(list try-cmd)
								object instance
								try-goal-or-action-vars 
								try-goal-or-action-params-translated
								no-nlp)) 
							  (cadr rest-evald)))
					  (list '() (cadr rest-evald)))))
				  (list t (try-to-nlp-ize-goal-action-list
					   '()
					   (list try-cmd)
					   object instance
					   try-goal-or-action-vars 
					   try-goal-or-action-params-translated
					   no-nlp)))
			      ;; action failed
			      (cond (and-case (list '() (cadr action-run)))
				    (or-case (run-goal-trys-h 
					      object instance goal 
					      goal-vars goal-var-values (cdr trys) 
					      orig-goals log-and-or just-explain no-nlp))
				    ;; and-or case (or's with previous failed trys as part of)
				    (t (let ((rest-evald 
					      (run-goal-trys-h 
					       object instance goal 
					       goal-vars goal-var-values (cdr trys) 
					       orig-goals log-and-or just-explain no-nlp)))
					 (if (car rest-evald)
					     (list t (cons (list try-cmd) (cadr rest-evald)))
					   (list '() (cdr rest-evald)))))))))
			 ;; this try is a goal to run
			 ((and (is-goal object try-goal-or-action)
			       ;; need to activate a sub-goal before trying
			       (> 2 (activate-goal instance try-cmd)))
			  (let* ((goal-run 
				  (run-goal instance try-goal-or-action 
					    try-goal-or-action-params-translated
					    orig-goals
					    just-explain no-nlp))
				 (goal-nlp-ized (car (try-to-nlp-ize-goal-action-list
						      '()
						      (list try-cmd)
						      object instance
						      try-goal-or-action-vars 
						      try-goal-or-action-params-translated
						      no-nlp)))
				 (goal-run-summary (if (= 0 (cadr goal-run)) 
						       (list goal-nlp-ized 
							     (caddr goal-run))
						     (cons pre-satisfied goal-nlp-ized))))
			    ;; first deactivate sub-goal we just attempted 
			    ;; (unless was orginally active)
			    (if (not (my-member try-cmd orig-goals))
				(deactivate-goal instance try-cmd))
			    ;; if sub-goal sucessfull
			    (if (car goal-run) 
				(if and-case
				    (if (null (cdr trys))
					(list t (list goal-run-summary))
				      (let ((rest-evald 
					     (run-goal-trys-h 
					      object instance goal 
					      goal-vars goal-var-values (cdr trys) 
					      orig-goals log-and-or just-explain no-nlp)))
					(if (car rest-evald)
					    (list t (cons
						     goal-run-summary 
						     (cadr rest-evald)))
					  (list '() (cadr rest-evald)))))
				  (list t (list goal-run-summary)))
			      ;; if not
			      (cond (and-case (list '() (caddr goal-run)))
				    (or-case (run-goal-trys-h 
					      object instance goal 
					      goal-vars goal-var-values (cdr trys) 
					      orig-goals log-and-or just-explain no-nlp))
				    ;; and-or case
				    (t (let ((rest-evald 
					     (run-goal-trys-h 
					      object instance goal 
					      goal-vars goal-var-values (cdr trys) 
					      orig-goals log-and-or just-explain no-nlp)))
					(if (car rest-evald)
					    (list t (cons
						     goal-run-summary 
						     (cadr rest-evald)))
					  (list '() (cadr rest-evald)))))))))
			 (t (cond (and-case (list '() '()))
				  (or-case (run-goal-trys-h 
					    object instance goal 
					    goal-vars goal-var-values (cdr trys) 
					    orig-goals log-and-or just-explain no-nlp))
				  ;; and-or case
				  (t (let ((rest-evald 
					     (run-goal-trys-h 
					      object instance goal 
					      goal-vars goal-var-values (cdr trys) 
					      orig-goals log-and-or just-explain no-nlp)))
					(if (car rest-evald)
					    (list t (cons
						     goal-run-summary 
						     (cadr rest-evald)))
					  (list '() (cadr rest-evald)))))))))))))))

  
(defun try-to-nlp-ize-goal-action-list (top-goal goal-action-list object instance vars vals no-nlp)
  (cond ((or no-nlp (get-opt 'no-nlp)) goal-action-list)
	((null goal-action-list) '())
	((listp (caar goal-action-list))
	 (cons
	  (try-to-nlp-ize-goal-action-list 
	   top-goal 
	   (car goal-action-list) object instance vars vals no-nlp)
	  (try-to-nlp-ize-goal-action-list 
	   top-goal 
	   (cdr goal-action-list) object instance vars vals no-nlp)))
	(t (let* ((isgoal (is-goal object (caar goal-action-list)))
		  (iswant (or top-goal (equal (caar goal-action-list) 'want)))
		  (isaction (and (not isgoal) (is-action object (caar goal-action-list))))
		  (the-goal-action (cond ((or isgoal isaction) (caar goal-action-list))
					 (iswant (caddar goal-action-list))
					 (t (cadar goal-action-list))))
		  (goal-action-means 
		   (cond (isgoal (goal-nlp-means-knowledge object the-goal-action))
			 (iswant (or (goal-nlp-when-knowledge object top-goal)
				     (goal-when-knowledge object top-goal)))
			 (isaction (action-nlp-means-knowledge object the-goal-action))
			 (t '())))
		  (what-to-use (if goal-action-means
				   (plug-in-bindings-values (cons object vars) 
							    (cons instance vals)
							    goal-action-means)
				 (car goal-action-list))))
	     (cons what-to-use
		   (try-to-nlp-ize-goal-action-list top-goal (cdr goal-action-list) 
						    object instance vars vals no-nlp))))))

(defun goal-list-to-nlp-paragraph (l)
  (cond ((get-opt 'no-nlp) l)
	((null l) "")
	((equal (car l) pre-satisfied) 
	 (concatenate 'string (list-to-string (append '(the goal that) (cdr l) '(is pre satisified)))
		      "."))
	((atom (car l)) (concatenate 'string (list-to-string l) "."))
	(t (let* ((sub-goals-part (insert-seperator 
				       (mapcar #'get-to-leaf-list (cadr l)) '(and then)))
		  (is-pre-sat (and (equal (caar sub-goals-part) pre-satisfied)
				   (null (cdr sub-goals-part))))
		  (sub-goals-part-to-use (if is-pre-sat (list (cdar sub-goals-part))
					   (mapcar #'(lambda (l) (my-remove pre-satisfied l)) 
						   sub-goals-part)))
		  (sub-goals (mapcar #'list-to-string sub-goals-part-to-use))
		  (this 
		   (if is-pre-sat
		       (append (list (list-to-string 
				      (append '(the goal that) (car l) 
					      '(is easily satisifed because the goal that))))
			       sub-goals (list (list-to-string '(is pre satisified))))
		     (cons (list-to-string (append '(because) (car l) '(so)))
			   sub-goals)))
		  (rest (mapcar #'goal-list-to-nlp-paragraph (cadr l))))
	     (string-list-to-string
	      (if (or (equal rest '("")) is-pre-sat)
		  (append this '("."))
		(append this (list "... NOW") rest)))))))

(defun intent-list-to-nlp-paragraph (l object instance)
  (cond ((get-opt 'no-nlp) (reverse l))
	(t (let* ((vars-vals (extract-action-goal-var-vals object l))
		  (nlp-ized (intent-list-to-nlp-paragraph-h1 
			     l (car vars-vals) (cadr vars-vals) object instance)))
	     (intent-list-to-nlp-paragraph-h2 nlp-ized)))))

(defun intent-list-to-nlp-paragraph-h1 (l vars vals object instance)
  (cond ((null l) l)
	(t (append (intent-list-to-nlp-paragraph-h1 
		    (cdr l) (cdr vars) (cdr vals) object instance)
		   (try-to-nlp-ize-goal-action-list '() (list (car l)) object instance 
						    (car vars) (car vals) '())))))

(defun intent-list-to-nlp-paragraph-h2 (l)
  (cond ((or (null l) (null (cdr l))) "")
	(t (concatenate 'string 
			(list-to-string (car l)) 
			", BECAUSE " 
			(list-to-string (cadr l))
			". "
			(intent-list-to-nlp-paragraph-h2 (cdr l))))))
						
			

;; ((((1))) 2 (3)) --> (1)
(defun get-to-leaf-list (l)
  (cond ((or (null l) (atom (car l))) l)
	(t (get-to-leaf-list (car l)))))

(defun is-instance (instance)
  (my-member instance (cars (world-instances current-world))))

(defun add-instance-list (world object instance)
  (setq instance-list 
	(cons (list world (cons (list instance object) (world-instances world)))
	      (remove-world-from-instance-list world))))

(defun add-last-action-list (instance action updated-instance updated-property old-value)
  (setq last-action-list
	(cons (list instance 
		    (cons (list action 
				(cons (list updated-instance updated-property old-value)
				      (last-action-list-updates-knowledge instance 
									  action)))
			  (remove-x-from-database 
			   action 
			   (last-action-list-action-knowledge instance))))
	      (remove-x-from-database instance last-action-list))))

(defun add-last-goal-list (instance goal updated-instance updated-property old-value)
  (setq last-goal-list
	(cons (list instance 
		    (cons (list updated-instance updated-property old-value)
			  (last-goal-list-updates-knowledge instance)))
	      (remove-x-from-database instance last-goal-list))))

(defun last-action-list-action-knowledge (instance)
  (last-action-list-action-knowledge-h instance last-action-list))

(defun last-action-list-action-knowledge-h (instance tmp-last-action-list)
  (cond ((null tmp-last-action-list) '())
	((equal (caar tmp-last-action-list) instance) (cadar tmp-last-action-list))
	(t (last-action-list-action-knowledge-h instance (cdr tmp-last-action-list)))))

(defun last-action-list-updates-knowledge (instance action)
  (last-action-list-action-knowledge-h 
   action 
   (last-action-list-action-knowledge instance)))

(defun last-goal-list-updates-knowledge (instance)
  (last-goal-list-updates-knowledge-h instance last-goal-list))

(defun last-goal-list-updates-knowledge-h (instance tmp-last-goal-list)
  (cond ((null tmp-last-goal-list) '())
	((equal (caar tmp-last-goal-list) instance) (cadar tmp-last-goal-list))
	(t (last-goal-list-updates-knowledge-h instance (cdr tmp-last-goal-list)))))

(defun reset-action-list-updates-knowledge (instance action)
  (setq last-action-list
	(cons (list instance 
		    (cons (list action 
				'())
			  (remove-x-from-database 
			   action 
			   (last-action-list-action-knowledge instance))))
	      (remove-x-from-database instance last-action-list))))

(defun reset-goal-list-updates-knowledge (instance)
  (setq last-goal-list
	(remove-x-from-database instance last-goal-list)))

(defun remove-x-from-database (x database)
  (cond ((null database) '())
	((equal (caar database) x) 
	 (remove-x-from-database x (cdr database)))
	(t (cons (car database)
		 (remove-x-from-database x (cdr database))))))

(defun world-instances (world)
  (world-instances-h world instance-list))

(defun world-instances-h (world tmp-instance-list)
  (cond ((null tmp-instance-list) '())
	((equal (caar tmp-instance-list) world) (cadar tmp-instance-list))
	(t (world-instances-h world (cdr tmp-instance-list)))))

(defun remove-world-from-instance-list (world)
  (remove-world-from-instance-list-h world instance-list))

(defun remove-world-from-instance-list-h (world tmp-instance-list)
  (cond ((null tmp-instance-list) '())
	((equal (caar tmp-instance-list) world) 
	 (remove-world-from-instance-list-h world (cdr tmp-instance-list)))
	(t (cons (car tmp-instance-list)
		 (remove-world-from-instance-list-h world (cdr tmp-instance-list))))))

(defun object-groups (object)
  (object-groups-h object (list-objects current-world)))

(defun object-groups-h (object all-objects)
  (cond ((null all-objects) '())
	((and (not (eq (car all-objects) object)) 
	      (member object (subobject-knowledge (car all-objects))))
	 (cons (car all-objects) (object-groups-h object (cdr all-objects))))
	(t (object-groups-h object (cdr all-objects)))))

(defun instance-object (instance)
  (hash-lookup instance (world-instances current-world)))

(defun get-instance-properties (instance)
  (cons instance (caadr (instance-lookup 
			 instance 
			 (instance-knowledge (instance-object instance))))))

(defun get-instance-properties-wo-instance (instance)
  (caadr (instance-lookup instance (instance-knowledge (instance-object instance)))))

(defun get-instance-active-goals (instance)
  (cadadr (instance-lookup instance (instance-knowledge (instance-object instance)))))

(defun instance-lookup (instance hash)
  (cond ((null hash) '())
	((equal (caar hash) instance) (car hash))
	(t (instance-lookup instance (cdr hash)))))

(defun list-instance-properties (instance)
  (list-var-vals (property-knowledge (instance-object instance))
		 (get-instance-properties instance)))

(defun list-instances-properties-of-all-object (world)
  (list-instances-properties-of-all-object-h (list-objects world)))

(defun list-instances-properties-of-all-object-h (objects)
  (cond ((null objects) '())
	(t (let ((the-object (car objects)))
	     (format t
		     "~%These are the ~ss: ~s"
		     the-object
		     (list-instances-properties  the-object))
	     (list-instances-properties-of-all-object-h (cdr objects))))))

(defun list-instances-properties (object)
  (list-instances-properties-h (list-instances current-world object)))

(defun list-instances-properties-h (instances)
  (cond ((null instances) '())
	(t (cons (list-instance-properties (car instances))
		 (list-instances-properties-h (cdr instances))))))

;; player1 opponent turn -> player2 turn -> no
(defun instance-property-recursive (instance-property)
  (let ((1st (car instance-property)) (2nd-on (cdr instance-property)))
    (cond ((= (length instance-property) 2)
	   ;; asking property or qualification of a "set" of instances
	   (if (setp 1st)
	       (set-of-instances-property 1st (car 2nd-on))
	     (instance-property 1st (car 2nd-on))))
	  (t (instance-property-recursive (cons (instance-property 1st (car 2nd-on)) 
					     (cdr 2nd-on)))))))

(defun instance-property (instance property)  
  (let ((object (instance-object instance)))
    (cond
     ;; asking a property     
     ((is-property object property)     
      (key-list-val-list-lookup
       property
       (property-knowledge object)
       (get-instance-properties instance)))
     ;; asking a qualification
     ((is-qualification object property)     
      (car (eval-multi-value-qualification object property instance)))
     (t '()))))

(defun set-of-instances-property (set-of-instances property)
  (let ((the-list (set-to-list set-of-instances)))
    (if (is-property (instance-object (car the-list)) property)
	(list-to-set (list-of-instances-property the-list property))
      unknown)))

(defun list-of-instances-property (list-of-instances property)
  (cond ((null list-of-instances) '())
	(t (cons (instance-property (car list-of-instances) property)
		 (list-of-instances-property (cdr list-of-instances) property)))))

(defun action-undo (instance action)
  (update-property-multi-times-simple (last-action-list-updates-knowledge instance action)
				      instance 
				      action))

(defun goal-undo (instance goal)
  (update-property-multi-times-simple (last-goal-list-updates-knowledge instance)
				      instance 
				      goal))

;; orig-instance and orig-action are the subject and action behind this property update
(defun update-property (instance property property-value orig-instance orig-action)
  (let ((property-name-and-value (list property property-value)))
    (add-last-goal-list orig-instance orig-action instance property 
			(instance-property instance property))
    (add-last-action-list orig-instance orig-action instance property 
			  (instance-property instance property))
    (update-soracle current-world 
		    (instance-object instance) instance 
		    '() '() '() property-name-and-value '() '() '() '() '())))

(defun update-property-multi-times-simple (updates orig-instance orig-action)
  (cond ((null updates) '())
	(t (let ((update (car updates))) 
	     (and (update-property (car update) 
				   (cadr update) 
				   (caddr update) 
				   orig-instance orig-action)
		  (update-property-multi-times-simple 
		   (cdr updates) 
		   orig-instance orig-action))))))

;; ((inst1 var1 = exp1) (inst1 var2 = exp2) (player1 opponent turn = yes) ..)
;; for each have to parse on '= to determine: 
;; ((exp leading to an instance) property = (exp to eval)) 
(defun update-property-multi-times (assignments orig-instance orig-action)
  (cond ((null assignments) '())
	(t (let ((asgmnt (car assignments)))
	     (cond
	      ;; for all assignment
	      ((and (eq (car asgmnt) 'for) (eq (cadr asgmnt) 'all))
	       (update-property-multi-times (append (translate-for-x-exps (list asgmnt) 'all)
						    (cdr assignments)) 
					    orig-instance orig-action))
	      (t (let* ((asgmnt-parsed (split-on-first-word asgmnt '=))
			(right-side-parsed (split-on-first-word (cadr asgmnt-parsed) 'is))
			(conseq-pred (cadr right-side-parsed))
			(property (car (last (car asgmnt-parsed))))
			(instance (eval-exp (remove property (car asgmnt-parsed)))))
		   (cond
		    ;; this consequence has a predicate
		    (conseq-pred
		     (if (eval-pred conseq-pred)
			 (cons (update-property instance property 
						(eval-exp (car right-side-parsed))
						orig-instance orig-action)
			       (update-property-multi-times (cdr assignments) 
							    orig-instance 
							    orig-action))
		       (update-property-multi-times (cdr assignments) 
						    orig-instance orig-action)))
		    (t (cons (update-property instance property 
					      (eval-exp (car right-side-parsed))
					      orig-instance orig-action)
			     (update-property-multi-times (cdr assignments) 
							  orig-instance 
							  orig-action)))))))))))

;; returns (value reason/true pred)
(defun eval-multi-value-qualification (object qualification-name instance)
  (let ((r (eval-multi-value-qualification-h object 
				    (get-multi-value-qualification object qualification-name) 
				    instance)))
    (eval-multi-value-qualification-h object 
				      (get-multi-value-qualification object qualification-name) 
				      instance)))

(defun eval-multi-value-qualification-h (object qualification instance)
  (cond ((null qualification) '())
	(t (let ((try-next-qualification 
		  (eval-qualification object (car qualification) instance)))
	     (cond ((and try-next-qualification 
			 (or (not (unknownp (car try-next-qualification)))
			     (null (cdr qualification))))    
		    try-next-qualification)
		   (t (eval-multi-value-qualification-h 
		       object (cdr qualification) instance)))))))

(defun eval-qualification (object qualification-value-and-pred instance)  
  (let* ((qualification-value (car qualification-value-and-pred))
	 (qualification-pred (cadr qualification-value-and-pred))
	 (qualification-pred-translated 
	  (if qualification-pred (my-replace-with-exceptions qualification-pred 
							     object 
							     instance
							     all-quantifiers)
	    '()))
	 (qualification-pred-evald 
	  (if qualification-pred 
	      (eval-pred qualification-pred-translated) 
	    t)))    
    (cond ((unknownp qualification-pred-evald) (list unknown qualification-pred-translated))
	  (qualification-pred-evald 
	   (list (eval-exp (my-replace-with-exceptions qualification-value 
						       object 
						       instance 
						       all-quantifiers))
		 qualification-pred-translated))		 
	  (t (list unknown qualification-pred-translated)))))

(defun get-qualification (object qualification-name)
  (hash-lookup qualification-name (qualification-knowledge object)))

(defun get-multi-value-qualification (object qualification-name)
  (duplicate-keys-hash-lookup qualification-name (qualification-knowledge object)))

(defun get-action (object action-name)
  (hash-lookup action-name (action-knowledge object)))	 

(defun get-action-sol (object action-name)
  (car (get-action object action-name)))

(defun get-action-nlp (object action-name)
  (cadr (get-action object action-name)))

(defun get-goal (object goal-name)
  (hash-lookup goal-name (goal-knowledge object)))	 

(defun get-goal-sol (object goal-name)
  (car (get-goal object goal-name)))

(defun get-goal-nlp (object goal-name)
  (cadr (get-goal object goal-name)))

(defun get-action-undo-cmd (instance action)
  (list instance 'undo action))
	 
(defun get-rel-qualification (world rel-qualification-name)
  (hash-lookup rel-qualification-name (world-rel-qualification-knowledge world)))    

;; return val for a key
;; ((key1 val1) (key2 val2)
(defun hash-lookup (key hash)
  (cond ((null hash) '())
	((equal (caar hash) key) (cadar hash))
	(t (hash-lookup key (cdr hash)))))

;; return val for a key
;; ((key1 val1) (key2 val2) (key1 val3)) key1 --> ((val1) (val3))
(defun duplicate-keys-hash-lookup (key hash)
  (cond ((null hash) '())
	((equal (caar hash) key) 
	 (cons (cadar hash) (duplicate-keys-hash-lookup key (cdr hash))))
	(t (duplicate-keys-hash-lookup key (cdr hash)))))

;; getting and setting global options
(defun get-opt (opt)
  (let ((val (hash-lookup opt global-opts)))
    (if (equal val the-false) '() val)))

(defun set-opt (opt val)
  (setq global-opts
	(cons (list opt val)
	      (remove-x-from-database opt global-opts))))
 
;; (key1 key2 ...) (val1 val2 ...)   
(defun key-list-val-list-lookup (key key-list val-list)
  (cond ((null key-list) '())
	((equal (car key-list) key) (car val-list))
	(t (key-list-val-list-lookup key (cdr key-list) (cdr val-list)))))

;; key new-value (key1 key2 ...) (val1 val2 ...)   
(defun key-list-val-list-update (key new-value key-list val-list)
  (cond ((null key-list) '())
	((equal (car key-list) key) (cons new-value (cdr val-list)))
	(t (cons (car val-list) 
		 (key-list-val-list-update key new-value (cdr key-list) (cdr val-list))))))

;; makes sure vars/vals lists have same length by resolving multi word varls:
;; (human dest) (bob bob home) --> (human dest) (bob his-home)
(defun var-to-val-map (vars vals)
  (cond ((null vars) '())
	((and (null (cdr vars)) (not (null (cdr vals))))
	 (cons (eval-exp vals) (var-to-val-map (cdr vars) (cdr vals))))
	(t (cons (car vals) (var-to-val-map (cdr vars) (cdr vals))))))

;; (x y) (2 3) (z = y + x) ---> (z = 3 + 2)
(defun plug-in-bindings-values (var-list val-list exp)
  (cond ((null var-list) exp)
	(t (plug-in-bindings-values (cdr var-list) (cdr val-list) 
				    (my-replace exp (car var-list) (car val-list))))))

;; (x y) (2 3) ((z = y + x) (m = y - 1) ..) 
(defun plug-in-bindings-values-multi-exp (var-list val-list exps)
  (cond ((null exps) '())
	(t (cons (plug-in-bindings-values var-list val-list (car exps))
		 (plug-in-bindings-values-multi-exp var-list val-list (cdr exps))))))

;; (x x) (2 3) (z = x + x) ---> (z = 2 + 3)
(defun plug-in-once-bindings-values (var-list val-list exp)
  (cond ((null var-list) exp)
	(t (plug-in-bindings-values (cdr var-list) (cdr val-list) 
				    (my-replace-once exp (car var-list) (car val-list))))))

;; x (1 2 3) (make x y) -> ((make 1 y) (make 2 y) (make 3 y))
(defun plug-in-bindings-values-cross-product (var val-list exp)
  (plug-in-bindings-values-cross-product-h var val-list (all-strings-to-pseudo-list exp)))

(defun plug-in-bindings-values-cross-product-h (var val-list exp)
  (cond ((null val-list) '())
	(t (cons (all-pseudo-lists-to-string 
		  (plug-in-bindings-values (list var) (list (car val-list)) exp))
		 (plug-in-bindings-values-cross-product-h var (cdr val-list) exp)))))

;; (x y) ((1 2) (3 4)) (make x y) -> ((make 1 3) (make 1 4) (make 2 3) (make 2 4))
(defun plug-in-bindings-values-full-cross-product (vars val-lists exp)
  (plug-in-bindings-values-full-cross-product-h vars (cross-product val-lists) exp))

(defun plug-in-bindings-values-full-cross-product-h (vars vals-cross-p exp)
  (cond ((null vals-cross-p) '())
	(t (cons (plug-in-bindings-values vars (car vals-cross-p) exp)
		 (plug-in-bindings-values-full-cross-product-h vars (cdr vals-cross-p) exp)))))

;; ((a b)) --> ((a) (b))
;; ((1 2) (3 4) (5 6)) --> ((1 3 5) (1 3 6) (1 4 5) (1 4 6) (2 3 5) (2 3 6) (2 4 5) (2 4 6))
(defun cross-product (lits)
  (cond ((null lits) '())
	((null (car lits)) '())
	((null (cdr lits)) (append (list (list (caar lits)))
				   (cross-product (list (cdar lits)))))
	((null (cadr lits)) '())
	((atom (car lits)) 
	 (cond ((null (cddr lits)) (append (list (list (car lits) (caadr lits)))
					   (cross-product (list (car lits) (cdadr lits)))))
	       (t (conss (car lits) (cross-product (cdr lits))))))
	(t (append (cross-product (cons (caar lits) (cdr lits)))
		   (cross-product (cons (cdar lits) (cdr lits)))))))		  

;; (x y z) (2 3 4) --> ((x = 2) (y = 3) (z = 4))
(defun list-var-vals (vars vals)
  (cond ((null vars) '())
	(t (cons (list (car vars) '= (car vals)) (list-var-vals (cdr vars) (cdr vals))))))

(defun yes-or-no (p)
  (cond ((unknownp p) unknown)
	(p the-true)
	(t the-false)))

(defun yes-no-to-bool (p)
  (if (equal p 'no) '() t))

(defun ith (list i)
  (cond ((= i 1) (car list))
	(t (ith (cdr list) (- i 1)))))

;; (A B) ((C D) (A B) (E F)) ((1 2) (3 4) (5 6)) --> (3 4)
(defun try-to-match (subl l1 l2)
  (cond ((null l1) '())
	((equal (car l1) subl) (car l2))
	(t (try-to-match subl (cdr l1) (cdr l2)))))

;; (a * c) (a b e c) () -> t
;; (* c) (c) () -> t
;; (a * c) (a b) () -> ()
;; (a * var) (a b blah) (var) -> t: (var blah)
(defun wild-card-match (l1 l2 extra-vars)
  (wild-card-match-h l1 l2 extra-vars '() '()))

(defun wild-card-match-h (l1 l2 extra-vars var-sofar val-sofar)
  (cond ((or (and (null l2) (null l1))
	     (equal l1 '(*)))
	     (list t var-sofar val-sofar))
	((null l2) (list '() var-sofar val-sofar))
	((null l1) (list '() var-sofar val-sofar))
	((equal (car l1) (car l2))
	 (wild-card-match-h (cdr l1) (cdr l2) extra-vars var-sofar val-sofar))
	((equal (car l1) (car extra-vars))
	 (wild-card-match-h (cdr l1) (cdr l2) 
			  (cdr extra-vars) (append var-sofar (list (car l1)))
			  (append val-sofar (list (car l2)))))
	((and (equal (car l1) '*)
	      (not (null (cdr l1)))
	      (not (equal (cadr l1) (car l2)))
	      (not (equal (cadr l1) (car extra-vars))))
	 (wild-card-match-h l1 (cdr l2) extra-vars var-sofar val-sofar))
	((equal (cadr l1) (car extra-vars))
	 (wild-card-match-h (cdr l1) (cdr l2) extra-vars var-sofar val-sofar))
	((equal (cadr l1) (car l2))
	 (wild-card-match-h (cddr l1) (cdr l2) extra-vars var-sofar val-sofar))
	(t (list '() var-sofar val-sofar))))
	 

;; (a (b) ((c))) --> (a b c)
(defun flatten (l)
  (cond ((null l) l)
	((atom (car l)) (cons (car l) (flatten (cdr l))))
	(t (append (flatten (car l)) (flatten (cdr l))))))

(defun list-intersection (l1 l2)
  (if (< (length l1) (length l2))
      (list-intersection-h l1 l2)
      (list-intersection-h l2 l1)))

(defun list-intersection-h (l1 l2)
  (cond ((null l1) '())
	((my-member (car l1) l2) (cons (car l1) (list-intersection-h (cdr l1) l2)))
	(t (list-intersection-h (cdr l1) l2))))

(defun my-member (e l)
  (cond ((null l) '())
	((equal e (car l)) t)
	(t (my-member e (cdr l)))))

;; '(fetch any) '((fetch gold) (find this)) --> t
(defun my-member-with-wild-card (e l)
  (cond ((null l) '())
	((is-match (car l) e) t)
	(t (my-member-with-wild-card e (cdr l)))))

;; '(a b 2) '(a b any) --> t
(defun is-match (list pattern)
  (cond ((equal list pattern) t)
	((and (null list) (null pattern)) t)
	((or (null list) (null pattern)) '())
	((or (equal (car list) (car pattern))
	     (equal (car pattern) 'any)) 
	 (is-match (cdr list) (cdr pattern)))
	(t '())))

(defun which-member (e l)
  (cond ((null l) -1)
	((equal e (car l)) 0)
	(t (let ((rest (which-member e (cdr l))))
	     (if (<= 0 rest) (+ 1 rest) rest)))))

(defun my-replace (list old new)
  (cond ((null list) '())
	((equal (car list) old) (cons new (my-replace (cdr list) old new)))
	((atom (car list)) (cons (car list) (my-replace (cdr list) old new)))
	(t (cons (my-replace (car list) old new) (my-replace (cdr list) old new)))))

(defun my-replace-with-exceptions (list old new prev-exceptors)
  (my-replace-with-exceptions-h list old new prev-exceptors '()))

(defun my-replace-with-exceptions-h (list old new prev-exceptors prev)
  (cond ((null list) '())
	((and (equal (car list) old) (not (my-member prev prev-exceptors))) 
	 (cons new 
	       (my-replace-with-exceptions-h (cdr list) old new prev-exceptors (car list))))
	((atom (car list)) 
	 (cons (car list) 
	       (my-replace-with-exceptions-h (cdr list) old new prev-exceptors (car list))))
	(t (cons (my-replace-with-exceptions-h (car list) old new prev-exceptors (car list)) 
		 (my-replace-with-exceptions-h (cdr list) old new prev-exceptors (car list))))))

(defun my-replace-once (list old new)
  (cond ((null list) '())
	((equal (car list) old) (cons new (cdr list)))
	(t (cons (car list) (my-replace (cdr list) old new)))))

;; make blah all player all row -> make blah "{ player1 player2 }" "{ 1 2 3 }"
(defun replace-all-object-tokens (cmd)
  (cond ((null cmd) '())
	((null (cdr cmd)) cmd)
	((and (equal (car cmd) 'all) (is-object (cadr cmd)))
	 (cons (list-to-set (list-instances current-world (cadr cmd)))
	       (replace-all-object-tokens (cddr cmd))))
	(t (cons (car cmd)
		 (replace-all-object-tokens (cdr cmd))))))

(defun find-first-object-in-exp (exp)
  (cond ((null exp) '())
	((is-object (car exp)) (car exp))
	(t (find-first-object-in-exp (cdr exp)))))

;; 2 random bob states degree --> (bob states) <--- a set
;; hack fixme.
(defun find-first-set-in-exp (exp)
  (cond ((null exp) '())
	((and (not (null (cdr exp))) (is-instance (car exp))) 
	 (let ((sub-exp-evald (eval-single-exp (list (car exp) (cadr exp)))))
	   (if (setp sub-exp-evald) 
	       (list sub-exp-evald (list (car exp) (cadr exp)))
	     (if (not (null (cddr exp)))
		 (let ((sub2-exp-evald (eval-single-exp (list (car exp) 
							      (cadr exp) 
							      (caddr exp)))))
		   (if (setp sub2-exp-evald)
		       (list sub2-exp-evald (list (car exp) (cadr exp) (caddr exp)))
		     (find-first-set-in-exp (cdr exp))))
	       (find-first-set-in-exp (cdr exp))))))
	((setp (car exp)) (list (car exp) (list (car exp))))
	(t (find-first-set-in-exp (cdr exp)))))

(defun last-element (l)
  (car (last l)))

(defun but-last (l)
  (cond ((null (cdr l)) '())
	(t (cons (car l) (but-last (cdr l))))))

; check any member of list a is in list b
(defun any-member (l1 l2)
  (cond ((null l2) '())
	((null l1) '())
	((my-member (car l1) l2) (car l1))
	(t (any-member (cdr l1) l2))))

(defun all-member (l1 l2)
  (cond ((null l1) t)
	((member (car l1) l2) (all-member (cdr l1) l2))
	(t '())))

(defun list-of-n-x (x n)
  (cond ((= n 0) '())
	(t (cons x (list-of-n-x x (- n 1))))))

(defun append-nth-element (x n l)
  (cond ((= n 0)
	 (append (list (append (car l) (list x))) (cdr l)))
	(t (cons (car l) (append-nth-element x (- n 1) (cdr l))))))

(defun cdrn (l n)
  (if (= n 0) l (cdrn (cdr l) (- n 1))))

;; l1 - l2
(defun remove-all (l1 l2)
  (cond ((null l2) l1)
	(t (remove-all (my-remove (car l2) l1) (cdr l2)))))

(defun my-remove (e l)
  (cond ((null l) l)
	((equal e (car l)) (my-remove e (cdr l)))
	(t (cons (car l) (my-remove e (cdr l))))))

(defun my-map (fn l)
  (cond ((null l) l)
	(t (cons (funcall fn (car l)) (my-map fn (cdr l))))))
 
(defun setp (s)
  (and (stringp s)
       (let ((s-l (string-to-list s)))
	 (and (eq (car s-l) '{)
	      (eq (car (reverse s-l)) '})))))

(defun set-add-element (s e)
  (if (my-member e (set-to-list s))
      s
    (list-to-set (append (set-to-list s) (list e)))))

(defun set-remove-element (s e)
      (list-to-set (remove e (set-to-list s))))

(defun set-add-set (s1 s2)
  (list-to-set (append (set-to-list s1) (set-to-list s2))))

(defun set-subtract-set (s1 s2)
  (list-to-set (remove-all (set-to-list s1) (set-to-list s2))))

(defun equal-sets (s1 s2)
  (let ((l1 (set-to-list s1)) (l2 (set-to-list s2)))
    (and (equal (length l1) (length l2))
	 (all-member l1 l2))))

(defun set-member-or-subset (set-or-element big-set)
  (cond ((setp set-or-element)
	 (all-member (set-to-list set-or-element) (set-to-list big-set)))
	(t (my-member set-or-element (set-to-list big-set)))))

(defun set-size (s)
  (length (set-to-list s)))

;; "{ 1 2 3 4 5 }" '(even = yes) -> "{ 2 4 }" 
(defun find-subset (set pred) 
  (let ((ans (find-subset-h (set-to-list set) pred)))
    (if (unknownp ans) unknown (list-to-set ans))))

(defun find-subset-h (list pred)
  (cond ((null list) '())      	
	(t (let ((evald (eval-pred (plug-in-bindings-values (list 'of) 
							    (list (car list)) 
							    pred))))
	     (cond ((true-and-known evald) 
		    (let ((next (find-subset-h (cdr list) pred))) 
		      (if (unknownp next) unknown (cons (car list) next))))
		   (evald unknown)
		   (t (find-subset-h (cdr list) pred)))))))

(defun yes-no-unknown (a b bool)
  (if (and (not bool) (any-unknown a b))
      unknown
    bool))

(defun abs-true (bool)
  (equal bool t))

(defun true-and-known (bool)
  (and bool (not (unknownp bool))))

(defun unknownp (a)
  (equal a unknown))

(defun knownp (a)
  (not (equal a unknown)))

(defun atomp (x)
  (and (atom x) x))

(defun any-unknown (a b)
  (or (unknownp a) (unknownp b)))

(defun valid-cmd-ret-val (ret-val)
  (eq (car ret-val) 0))

(defun pseudo-listp (list)
  (and (not (null list)) (eq (car list) 'pseudo-list)))

(defun quantifier-predp (pred)
  (and (eq (car pred) 'for) (member (cadr pred) log-quantifiers)))

(defun last-comp-op (clause)
  (cond ((null clause) '())
	((and (member (car clause) math-comps) (not (any-member math-comps (cdr clause))))
	 (car clause))
	(t (last-comp-op (cdr clause)))))

(defun print-these (things)
  (let ((1st (or (and (atomp (car things)) (list (car things))) (car things)))
	(2nd (or (and (atomp (cadr things)) (list (cadr things))) (cadr things)))
	(3rd (or (and (atomp (caddr things)) (list (caddr things))) (caddr things)))
	(4th (or (and (atomp (cadddr things)) (list (cadddr things))) (cadddr things)))
	(5th (or (and (atomp (cadddr (cdr things))) 
		      (list (cadddr (cdr things)))) (cadddr (cdr things)))))
    (print (list-to-string 
	    (append 1st 2nd 3rd 4th 5th)))))
 
(defun print-list (l)
  (cond ((null l) t)
	((atom (caar l))
	 (and (print (car l)) (print-list (cdr l))))
	(t (and (print-list (car l)) (print-list (cdr l))))))

(defconstant the-false 'no)
(defconstant the-true 'yes)
(defconstant booleans (list the-false the-true))
(defconstant unknown 'unknown)
(defconstant empty-set "{ }")
(defconstant log-ops '(and or))
(defconstant log-quantifiers '(any every))
(defconstant all-quantifiers '(all any every))
(defconstant eng-one-articles '(a an))
(defconstant eng-def-articles '(the))
(defconstant eng-articles (append eng-one-articles eng-def-articles))
(defconstant math-ops '(- + / *))
(defconstant math-comps '(= > < >= <= in))
(defconstant goal-keywords '(when requires try consequence))
(defconstant pre-satisfied 'pre-satisfied-->)

