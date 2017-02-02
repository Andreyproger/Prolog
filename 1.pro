/*2_task.pro*/
p1(X,Y,Z):- Z = X + Y.
p2(X,Y,Z):- Z is X + Y.

/*3_task.pro*/
fact(0, 1).
fact(N, R) :- N > 0, N1 is N - 1, fact(N1, R1), R is R1 * N.

/*4_task.pro*/
fact(0, 1).
fact(1, 1).
fact(N, R) :- N > 0,  N mod 2 =:= 0,  N1 is N - 2, fact(N1, R1), R is R1 * N.
fact(N,R) :- N > 1, N mod 2 =\= 0, N1 is N - 2, fact(N1, R1), R is R1 * N.

/*5_task.pro*/
even(N) :- N mod 2 =:= 0, !.
even(N) :- N mod 2 =\= 0, fail.

/*6_task.pro*/
prime(N) :- primediv(2, N).
	primediv(div1, N) :- div1>sqrt(N),!;
	div1 < sqrt(N), N mod div1 =:= 0,!;
	div1 < sqrt(N), N mod div1 =\= 0, div11 is div1 + 1, primediv(div11, N).
  
/*7_task.pro*/
sirakuz(N,A0):- sirakuzit(1,N,A0).
  sirakuzit(K,N,A0):- N<K,!;
    K=<N, K mod 2 =:=0, KK is K+1, An is A0 div 2, write(An), 
      nl, sirakuzit(KK,N,An);
    K=<N, K mod 2 =\=0, KK is K+1, An is 3*A0+1, write(An), 
      nl, sirakuzit(KK,N,An).
