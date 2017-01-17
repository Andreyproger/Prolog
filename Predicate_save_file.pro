:- dynamic(clouse_term_body/2).

%.... Предикаты для примера
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

% не станет записыватья, т.к. не объявлен как public.
intTolist(0,Lst,Lst) :- !.
intTolist(N,Lst,Res) :-
	N1 is N div 10,
	N2 is N mod 10,
	intTolist(N1,[N2|Lst],Res).

%....

clouse_term_body(Head,Term_Body) :-
	nonvar(Head),
	clause(Head,Term_Body); !, fail.	

control_result(FileName) :- \+ file_exists(FileName), !, fail.
control_result(FileName) :-
	file_property(FileName,size(Size)),
	Size = 0 -> !, fail;
	true, !.

arg_mask([],Hash,Res) :- reverse(Hash,Res), !.
arg_mask([El|B],Hash,Res) :-
	(var(El) -> Op = 'N'; Op = El),
	arg_mask(B,[Op|Hash],Res).

save(FileName) :-
	unlink(FileName),
	predicate_property(Head, public),
	forall(processfile3(FileName,Head),Head),
	control_result(FileName).

save(FileName,Head) :-
	unlink(FileName),
	Head =.. [TN|Body],
	functor(Head,TN,Arn),
	functor(UnHead,TN,Arn),
	arg_mask(Body,[],Arg_Mask),
	\+ memberchk('N',Arg_Mask), !,
	forall(processfile1(FileName,UnHead,Arg_Mask),UnHead),
	control_result(FileName).

save(FileName,Head) :-
	unlink(FileName),
	Head =.. [TN|Body],
	functor(Head,TN,Arn),
	length(AM_L,Arn),
	arg_mask(Body,[],Arg_Mask),
	arg_mask(AM_L,[],Arg_Mask), !,
	forall(processfile3(FileName,Head),Head),
	control_result(FileName).

save(FileName,Head) :-
	unlink(FileName),
	Head =.. [_|Body],
	arg_mask(Body,[],Arg_Mask),
	forall(processfile2(FileName,Head,Arg_Mask),Head),
	control_result(FileName).

processfile1(FileName,Head,Arg_Mask) :-
	clouse_term_body(Head,Term_Body),
	Head =.. [_|Body], arg_mask(Body,[],AM),
	AM = Arg_Mask,
	Term =.. [:-,Head,Term_Body],
	save_term_in_file(FileName,Term).

processfile2(FileName,Head,Arg_Mask) :-
	clouse_term_body(Head,Term_Body),
	Head =.. [_|Body], arg_mask(Body,[],AM),
	AM \= Arg_Mask,
	Term =.. [:-,Head,Term_Body],
	save_term_in_file(FileName,Term).

processfile3(FileName,Head) :-
	clouse_term_body(Head,Term_Body),
	Term =.. [:-,Head,Term_Body],
	save_term_in_file(FileName,Term).

save_term_in_file(FileName,Term) :-
	telling(Old),
	append(FileName),
	portray_clause(Term), nl,
	told,
	tell(Old).
