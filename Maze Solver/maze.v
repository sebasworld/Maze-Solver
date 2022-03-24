`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:01 11/29/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze(
		input clk,
		input [maze_width - 1:0]  starting_col, starting_row, 	// indicii punctului de start
		input maze_in, 			// ofera informatii despre punctul de coordonate [row, col]
		output reg [maze_width - 1:0] row, col,	 		// selecteaza un rând si o coloana din labirint
		output reg maze_oe,			// output enable (activeaza citirea din labirint la rândul si coloana date) - semnal sincron	
		output reg maze_we, 			// write enable (activeaza scrierea în labirint la rândul si coloana date) - semnal sincron
		output reg done);		 	// iesirea din labirint a fost gasita; semnalul ramane activ 


`define initialize 0
`define choose_direction 1
`define check_new_cell 2
`define check_right_cell 3
`define change_or_keep_direction 4
`define check_front_cell 5 
`define keep_forward_or_go_left 6
`define check_if_solved 7


parameter maze_width = 6;
reg [maze_width - 1:0] prev_row, prev_col; // variabilele care retin coordonatele pozitiei anterioare
reg [1:0] d; // variabila pentru posibilele directii de deplasare: 0 - jos, 1 - stanga, 2 - sus, 3 - dreapta

reg [2:0] state, next_state;

always @(posedge clk) begin
		state <= next_state;
end

always @(*) begin
		next_state = `initialize; // prima stare va fi cea de inceput
		maze_oe = 0;
		maze_we = 0;
		done = 0;
		
		case(state)
				`initialize: begin
				
						row = starting_row;  // setez row si col ca fiind coordonatele punctului de inceput
						col = starting_col;
						
						
						maze_we = 1; // scriu 2 in celula de plecare deoarece este libera
						d = 0; // presupun ca initial aleg sa plec in jos
						
						
						next_state = `choose_direction;
				end
				
				`choose_direction: begin // ma uit in fiecare directie pt a le verifica in starea urmatoare
				
						prev_row = row; // salvez pozitia initiala inainte de a incepe verificarea
						prev_col = col;
						
						case(d)
								0: begin
										row = row + 1; //  verific jos
								end
								
								1: begin
										col = col - 1; // verific la stanga 
								end
								
								2: begin 
										row = row - 1; //  verific sus
								end
								
								3: begin 
										col = col + 1; // verific la dreapta
								end	
						endcase
						
						maze_oe = 1; // apelez maze_oe pt a vedea daca celula este un perete sau este libera in urmatoarea stare
						
						next_state = `check_new_cell;
				end

				`check_new_cell: begin	
						
						if(maze_in == 0) begin // daca celula este libera, raman in aceasta si incep algoritmul de verificare la dreapta
								
								maze_we = 1; // marchez noua celula cu 2
								next_state = `check_right_cell;	
						end
						else begin // daca celula este un perete, ma intorc inapoi
							
								col = prev_col; // revin la pozitia precedenta si aleg alta directie
								row = prev_row;
								
								d = d + 1; // incerc urmatoarea directie
								
								next_state = `choose_direction; 
						end
				end
				
				`check_right_cell: begin // verific daca pot merge la dreapta in functie de ce directie a fost urmata
						
						prev_col = col; // retin pozitia curenta inainte de a verifica
						prev_row = row;
						
						case(d) 
								0: begin
										col = col - 1; // daca directia este jos -> verific in stanga
								end
						
								1: begin
										row = row - 1; // daca directia este in stanga -> verific in sus
								end
								
								2: begin
										col = col + 1; // daca directia este sus -> verific spre dreapta
								end
								
								3: begin
										row = row + 1; // daca directia este in dreapta-> verific in jos
								end
						endcase
						
						maze_oe = 1; // activez maze_oe pt a vedea cum este celula din dreapta in starea urmatoare
						
						next_state = `change_or_keep_direction;
				end
				
				`change_or_keep_direction: begin  // aici decid daca modific directia, dupa ce aflu prin maze_in cum este noua celula
						
						if(maze_in == 0) begin // daca celula e libera, raman in ea si verific daca am terminat maze-ul
							
								case(d) 
										0: begin
												d = 1; // jos -> stanga
										end
										
										1: begin
												d = 2; // stanga -> sus
										end

										2: begin
												d = 3; // sus -> dreapta
										end
										
										3: begin
												d = 0; // dreapta -> jos
										end
								endcase
								
								maze_we = 1; // marchez noua celula cu 2
								next_state = `check_if_solved;
						end
						
						else begin // daca celula este un perete, ma intorc si trec in urmatoarea stare unde o verific pe cea din fata
						
								col = prev_col; // ma intorc in celula anterioara
								row = prev_row;
							
								next_state = `check_front_cell;
						end
				end
				
				`check_front_cell: begin // aici verific daca pot merge inainte deoarece la dreapta am perete
						
						prev_col = col; // retin pozitia inainte de a verifica
						prev_row = row;
	
						case(d)
								0: begin
										row = row + 1; // jos
								end
								
								1: begin
										col = col - 1; // stanga
								end
								
								2: begin 
										row = row - 1; // sus
								end
								
								3: begin 
										col = col + 1; // dreapta
								end
						endcase
							
						maze_oe = 1; // apelez maze_oe pt a vedea cum este celula din fata in urmatoarea stare
						
						next_state = `keep_forward_or_go_left;
				end
			
				`keep_forward_or_go_left: begin // daca nu ma pot deplasa nici inainte (nici la dreapta), merg spre stanga
						
						if(maze_in == 0) begin // pastrez drumul inainte, daca celula din fata e libera
						
								maze_we = 1; // marchez cu 2 campul din fata
								
						end
						
						else begin // schimb directia spre stanga, daca celula din fata e perete
						
								col = prev_col; // ma intorc la pozitia anterioara
								row = prev_row; 
								
								case(d)
										0: begin
												d = 3; // jos -> dreapta
										end
										
										1: begin
												d = 0; // stanga -> jos
										end

										2: begin
												d = 1; // sus -> stanga
										end
									
										3: begin
												d = 2; // dreapta -> sus
										end
								endcase
						end
								
						maze_oe = 1; // il apelez pt verificarea finala
						next_state = `check_if_solved;
						
				end
				
				
				`check_if_solved: begin // in starea asta verific daca am ajuns la iesire
				
						if(maze_in == 0 && (row == 0 || row == 63 || col == 0 || col == 63)) begin //daca sunt la margine si celula e libera,
																															// am iesit din labirint 
								
								maze_we = 1; // marchez cu 2 pozitia
								
								done = 1; //  activez done pt ca am terminat maze-ul
						end
						
						else begin //daca conditiile de finish nu-s indeplinite, revin la check_right_cell
										
								next_state = `check_right_cell;
						end
				end
								
	endcase
end														

endmodule
