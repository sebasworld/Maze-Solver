
Am folosit algoritmul Wall Follower de parcurgere a labirintului care asigura gasirea unei iesiri prin schimbarea la dreapta continua a directiei atunci cand acest lucru este posibil, urmarind astfel peretele din dreapta.

	Nefiind posibila cache-uirea matricei ce reprezinta maze-ul, singurele variabile pe care le-am folosit pe langa input-urile si output-urile date sunt:
	
•	prev_row si prev_col – retin coordonatele pozitiei anterioare
•	d – retine directia de deplasare si poate fi: 0 – jos, 1 – stanga, 2 – sus, 3 – dreapta


	Pentru implementarea algortimului am folosit 8 stari pe care le voi explica in parte:
	
	
0.	initialize
In prima stare, se preiau coordonatele de start si marchez celula de plecare cu 2 ca fiind valida, apoi setez la alegere directia initiala de deplasare in jos (posibil sa nu fie valida, acest lucru va fi verificat).

1.	choose_direction
Odata preluata celula initiala, ma uit in fiecare directie posibila, salvand pozitia initiala, si solicit cu ajutorul maze_oe un feedback pentru a gasi plecarea corecta.

2.	check_new_cell
In aceasta stare, in functie de valoarea data de maze_in, parasesc startul, ma mut in celula noua si o marchez cu 2 daca aceasta se dovedeste a fi goala , iar daca aceasta este un perete, ma intorc la inceput si verific directia urmatoare pana gasesc una valida. 

3.	check_right_cell
Dupa ce am parasit celula initiala pentru una noua, gasind o cale libera, incep sa urmez algortimul de verificare la dreapta. In functie de pe ce directie s-a plecat, ma voi uita in dreapta, salvand pozitia curenta si solicitand iarasi feedback cu maze_oe pentru a verifica o posibila schimbare de directie in starea urmatoare.


4.	change_or_keep_direction
Odata primit feedback-ul de la maze_in, pentru fiecare directie in parte, imi schimb deplasarea la dreapta directiei curente (jos devine stanga, stanga devine sus, sus devine dreapta si dreapta devine jos) si marchez celula in cazul in care este libera. Daca spatiul este un perete, revin la pozitia precedenta si ma pregatesc sa verific celula din fata.

5.	check_front_cell
In starea aceasta, ma uit la celula din fata in cazul fiecarei directii si salvez pozitia curenta.
Apelez maze_oe pt ca starea urmatoare sa primesc feedback si sa aflu daca merg inainte sau spre stanga.

6.	keep_forward_or_go_left
In cazul in care celula este libera, marchez campul si trec in starea de verificare a rezolvarii labirintului. In caz contrar, daca gasesc si in fata un perete, ma intorc spre stanga si trec tot in starea de verificare finala.

7.	check_if_solved
In starea aceasta, daca celula e libera si coordonatele pozitiei reprezinta marginile labirintului activez semnalul done si marchez cu 2 pozitia.
In caz contrar voi reveni din nou la starea de check_right_cell pt a urma in continuare algoritmul.

