myremove([X|Xs],X,Xs).
myremove([X|Xs],E,[X|Ys]) :- myremove(Xs,E,Ys).
mypermutation([],[]).
mypermutation(Xs,[X|Ys]) :- myremove(Xs,X,Zs), mypermutation(Zs,Ys).
mysorted([]).
mysorted([_]).
mysorted([X,Y|T]) :- X=<Y,mysorted([Y|T]).
mysort(X,Y) :- mypermutation(X,Y),mysorted(Y).
