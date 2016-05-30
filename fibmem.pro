% fib2/2(+Index, ?FibNum)
:- dynamic(fib2/2).

fib2(0,1) :- !.
fib2(1,1) :- !.
fib2(N,Res) :- N > 0, 
  N1 is N - 1,
  fib2(N1, F1),
  N2 is N1 - 1,
  fib2(N2, F2),
  Res is F1 + F2,
  F =.. [fib2,N,Res],
  ToAdd =.. [:-, F, !],
  asserta(ToAdd).
% asserta - вставляет в начало
% assertz - вставляет в конец
% F =.. [.........]. 
