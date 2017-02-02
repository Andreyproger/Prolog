% 3
rEverse1(List1, List2) :- reverse(List1, List2).
rEverse2(Lst1, Lst2) :- rev(L1, L2).
rev([],[]),!.
rev([H1|_],[H2|_]) :- H1 =:= H2.
rev([H1|T1],[H2|T2]) :- H1 =:= H2, rEverse2(T1, T2). 

% 4
myReverse(X,Y):- myRev(X,[],Y).
myRev([],X,X):-!.
myRev([],X,Y):- X\=Y,fail,!.
myRev([Head|Tail],Buffer,List):-
	myRev(Tail,[Head|Buffer],List).

prime(X):-
	X>1,
	Y is X-1,
	prime_iter(X,Y).

prime_iter(_,1).
prime_iter(N,M):-
	N mod M =\=0,
	M1 is M-1,
	prime_iter(N,M1).

%5 Prefix
pref([],_):-!.
pref(_, []) :-!, fail.
pref([X|Xs],[Y|Ys]):- X = Y, pref(Xs,Ys).

include([],[]) :-!.
include(_,[]) :- fail,!.
include(X, [H|T]) :- pref(X, [H|T]).
include(X, [H|T]) :- include(X, T),!.

%6 Append_list
append1(LST1, LST2, LST3) :- iter(LST1, LST2, LST3).
iter([],[],[]).
iter([], [H2|_], [H2|_]).
iter([H1|_], [], [H1|_]).
iter([H1|T1],[H2|T2],LST3) :- H1 < H2, append1(T1,[H2|T2],[H1|LST3]).
iter([H1|T1],[H2|T2],LST3) :- H1 > H2, append1(T1,[H2|T2],[H1|LST3]).
iter([H1|T1],[H2|T2],LST3) :- H1 = H2, append1(T1,T2,[H1|LST3]).

%8 Quick_sort
qSort([],[]).
qSort([X|Xs],Ys) :- partition(Xs,X,L,R), qSort(L,Ls), qSort(R,Rs), append(Ls,[X|Rs],Ys).

partition([],Y,[],[]).
partition([X|Xs],Y,[X|Ls],Rs) :- X =< Y, partition(Xs,Y,Ls,Rs).
partition([X|Xs],Y,Ls,[X|Rs]) :- X > Y, partition(Xs,Y,Ls,Rs).

append([],Ys,Ys).
append([X|Xs],Ys,[X|Zs]) :- append(Xs,Ys,Zs).
