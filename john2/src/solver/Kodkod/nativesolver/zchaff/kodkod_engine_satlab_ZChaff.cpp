#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cassert>

#include <map>
#include <set>
#include <vector>
#include <list>
#include <string>
#include <algorithm>
#include <queue>

using namespace std;

#include "zchaff_solver.h"

#include <jni.h>
#include "kodkod_engine_satlab_ZChaff.h"

JNIEXPORT jlong JNICALL Java_kodkod_engine_satlab_ZChaff_make
  (JNIEnv *, jclass) {
	CSolver* solver = new CSolver();
	
	//cout << "new solver has " << solver->num_clauses() << " clauses" << endl;
	//cout << "new solver has " << solver->num_variables() << " variables" << endl;
	
	return ((jlong) solver);
}

JNIEXPORT void JNICALL Java_kodkod_engine_satlab_ZChaff_free
  (JNIEnv *, jobject, jlong solver) {
    delete ((CSolver*)solver);
}

JNIEXPORT void JNICALL Java_kodkod_engine_satlab_ZChaff_addVariables
  (JNIEnv *, jobject, jlong solver, jint numVars) {
  
  CSolver* solverPtr = (CSolver*) solver;
  
  //cout << "adding " << numVars << " variables to " << solver << endl;
  //cout << "# vars in the solver " << solverPtr->num_variables() << endl;
  
  if (solverPtr->num_variables()==0) {
   solverPtr->set_variable_number(numVars);
  } else {
   for(int i = 0; i < numVars; ++i) {
     solverPtr->add_variable();
   }
  }
  
  //cout << "added " << numVars << " variables to " << solver << endl;
}

JNIEXPORT jboolean JNICALL Java_kodkod_engine_satlab_ZChaff_addClause
  (JNIEnv * env, jobject, jlong solver, jintArray clause) {
    jsize length = env->GetArrayLength(clause);
    jint* buf = env->GetIntArrayElements(clause, JNI_FALSE);
    for(int i = 0; i < length; ++i) {
        int var = *(buf+i);
        *(buf+i) = var < 0 ? (-var << 1) | 1 : var << 1;
    }
    ClauseIdx clauseIdx = ((CSolver*)solver)->add_orig_clause((int*)buf, length);
    env->ReleaseIntArrayElements(clause, buf, 0);
    return clauseIdx>=0;
}

JNIEXPORT jboolean JNICALL Java_kodkod_engine_satlab_ZChaff_solve
  (JNIEnv *, jobject, jlong solver) {
  int status = ((CSolver*)solver)->solve();
  assert (status == UNSATISFIABLE || status == SATISFIABLE);
  return (status == SATISFIABLE);
}

JNIEXPORT jboolean JNICALL Java_kodkod_engine_satlab_ZChaff_valueOf
  (JNIEnv *, jobject, jlong solver, jint literal) {
  return ((CSolver*)solver)->variable(literal).value()==1;
}
