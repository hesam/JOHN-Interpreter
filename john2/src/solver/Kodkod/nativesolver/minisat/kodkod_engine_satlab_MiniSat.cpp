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

#include "Solver.h"

#include <jni.h>
#include "kodkod_engine_satlab_MiniSat.h"

/*
 * Class:     kodkod_engine_satlab_MiniSat
 * Method:    make
 * Signature: ()J
 */
JNIEXPORT jlong JNICALL Java_kodkod_engine_satlab_MiniSat_make
  (JNIEnv *, jclass) {
  Solver* solver = new Solver();
  //cout << "Created new minisat solver " << solver << endl;
  //cout << "new solver has " << solver->nVars() << " variables" << endl;
  return ((jlong) solver);
}

/*
 * Class:     kodkod_engine_satlab_MiniSat
 * Method:    free
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_kodkod_engine_satlab_MiniSat_free
  (JNIEnv *, jobject, jlong solver) {
  //cout << "destructing minisat solver " << solver << endl;
  delete ((Solver*)solver);  
}

/*
 * Class:     kodkod_engine_satlab_MiniSat
 * Method:    addVariables
 * Signature: (JI)V
 */
JNIEXPORT void JNICALL Java_kodkod_engine_satlab_MiniSat_addVariables
  (JNIEnv *, jobject, jlong solver, jint  numVars) {
  Solver* solverPtr = (Solver*) solver;
  //cout << "minisat solver " << solver << " has " << solverPtr->nVars() << " variables" << endl; 
  //cout << "adding " << numVars << " variables to minisat solver " << solver << endl;
  for(int i = 0; i < numVars; ++i) {
     solverPtr->newVar();
  }
}

/*
 * Class:     kodkod_engine_satlab_MiniSat
 * Method:    addClause
 * Signature: (J[I)Z
 */
JNIEXPORT jboolean JNICALL Java_kodkod_engine_satlab_MiniSat_addClause
  (JNIEnv * env, jobject, jlong solver, jintArray clause) {
    jsize length = env->GetArrayLength(clause);
    jint* buf = env->GetIntArrayElements(clause, JNI_FALSE);
    Solver* solverPtr = ((Solver*)solver);
    vec<Lit> lits;
    for(int i = 0; i < length; ++i) {
        int var = *(buf+i);
        lits.push((var > 0) ? Lit(var-1) : ~Lit(-var-1));
    }
    solverPtr->addClause(lits);
    env->ReleaseIntArrayElements(clause, buf, 0);
    return solverPtr->okay();
 }

/*
 * Class:     kodkod_engine_satlab_MiniSat
 * Method:    solve
 * Signature: (J)Z
 */
JNIEXPORT jboolean JNICALL Java_kodkod_engine_satlab_MiniSat_solve
  (JNIEnv *, jobject, jlong solver) {
   return ((Solver*)solver)->solve();
  }

/*
 * Class:     kodkod_engine_satlab_MiniSat
 * Method:    valueOf
 * Signature: (JI)Z
 */
JNIEXPORT jboolean JNICALL Java_kodkod_engine_satlab_MiniSat_valueOf
  (JNIEnv *, jobject, jlong solver, jint var) {
  return ((Solver*)solver)->model[var-1]==l_True;
 }

