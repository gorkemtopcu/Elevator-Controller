`timescale 1ns / 1ps

module elevator_control_module(
    input rst,
    input clk,
    input floor_0_p, floor_1_p, floor_2_p, floor_3_p, floor_4_p,
    input direction_1, direction_2, direction_3,
    input floor_0_d ,floor_1_d, floor_2_d,floor_3_d, floor_4_d,
    output reg led_inside_0, led_inside_1, led_inside_2, led_inside_3, led_inside_4,
    output reg led_outside_0, led_outside_1, led_outside_2, led_outside_3, led_outside_4,
    output reg led_busy,
    output reg [7:0] a, b, c, d, e, f, g, p
    );

    parameter FL_IDX0 = 3'b000, FL_IDX1 = 3'b001, FL_IDX2 = 3'b010, FL_IDX3 = 3'b011, FL_IDX4 = 3'b100; // floor indices
    parameter FLOOR0 = 5'b00001, FLOOR1 = 5'b00010, FLOOR2 = 5'b00100, FLOOR3 = 5'b01000, FLOOR4 = 5'b10000; // floors
    parameter IDLE = 2'b00, UP = 2'b01, DOWN = 2'b10; // states
    
    reg [4:0] current_floor;
    reg [4:0] next_floor;
    reg [2:0] current_fl_idx, next_fl_idx;
    
    reg [1:0] current_state;
    reg [1:0] next_state;
    reg [1:0] intermediate_state;
    
    //counter to slow the input clock
    reg [7:0] counter;
    
    // floor states
    reg [4:0] call_floor;
    
    //busy state
    reg busy_state;
    
    //sequential part - state transitions
    always@(posedge clk or negedge rst)
    begin
        if (~rst)begin
            current_floor <= FLOOR0;
            current_fl_idx <= FL_IDX0;
            current_state <= IDLE;
            led_busy <= 0;
            counter <= 0;
        end
        else begin
            if(counter == 8'b11111010) begin	 // if equal to 250
                // status change
                current_state <= next_state;
                // led busy change
                led_busy <= busy_state;
                // floor change
                current_floor <= next_floor;
                current_fl_idx <= next_fl_idx;
                // restart counter
                counter <= 0;
            end
            else counter <= counter + 1; // if not 250 add 1
        end
    end
    
    // next floor definitions
    always @(*)
    begin
      case(current_floor)
        FLOOR0:begin
            if(current_state == IDLE || call_floor[current_fl_idx])begin
                next_floor <= FLOOR0;
                next_fl_idx <= FL_IDX0;
            end 
            else if(current_state == UP)begin
                next_floor <= FLOOR1;
                next_fl_idx <= FL_IDX1;
            end
            else begin
                next_floor <= FLOOR0;
                next_fl_idx <= FL_IDX0;
            end
         end
        FLOOR1:begin
            if(current_state == IDLE || call_floor[current_fl_idx])begin
                next_floor <= FLOOR1;
                next_fl_idx <= FL_IDX1;
            end
            else if(current_state == UP)begin 
                next_floor <= FLOOR2;
                next_fl_idx <= FL_IDX2;
            end
            else if(current_state == DOWN)begin 
                next_floor <= FLOOR0;
                next_fl_idx <= FL_IDX0;
            end
            else begin
                next_floor <= FLOOR1;
                next_fl_idx <= FL_IDX1;
            end
        end
        FLOOR2:begin
            if(current_state == IDLE || call_floor[current_fl_idx])begin
                next_floor <= FLOOR2;
                next_fl_idx <= FL_IDX2;
            end
            else if(current_state == UP)begin 
                next_floor <= FLOOR3;
                next_fl_idx <= FL_IDX3;
            end
            else if(current_state == DOWN)begin 
                next_floor <= FLOOR1;
                next_fl_idx <= FL_IDX1;
            end
            else begin
                next_floor <= FLOOR3;
                next_fl_idx <= FL_IDX3;
            end
        end
        FLOOR3:begin;
            if(current_state == IDLE || call_floor[current_fl_idx])begin 
                next_floor <= FLOOR3;
                next_fl_idx <= FL_IDX3;
            end
            else if(current_state == UP)begin 
                next_floor <= FLOOR4;
                next_fl_idx <= FL_IDX4;
            end
            else if(current_state == DOWN)begin 
                next_floor <= FLOOR2;
                next_fl_idx <= FL_IDX2;
            end
            else begin
                next_floor <= FLOOR3;
                next_fl_idx <= FL_IDX3;
            end
        end
        FLOOR4:begin
            if(current_state == IDLE || call_floor[current_fl_idx])begin // if idle state or there is a call here
                next_floor <= FLOOR4; 
                next_fl_idx <= FL_IDX4;
            end
            else if(current_state == DOWN)begin 
                next_floor <= FLOOR3;
                next_fl_idx <= FL_IDX3;
            end
            else begin
                next_floor <= FLOOR4; 
                next_fl_idx <= FL_IDX4;
            end
        end
        default: begin
            next_floor <= FLOOR0;
            next_fl_idx <= FL_IDX0;
        end
      endcase
    end

    // Status state machine
    always@ (*)begin
        case (current_state)
            IDLE:begin
                busy_state <= 0;
                if(call_floor)begin // there is a call
                    if(call_floor[current_fl_idx]) next_state = IDLE; // call is at current floor
                    else if(call_floor > current_floor) next_state = UP; // call is at upper floors
                    else if (call_floor < current_floor) next_state = DOWN; // call is at lower floors
                    else next_state = IDLE;
                end
                else next_state <= IDLE;
            end
            UP:begin
                if(call_floor[current_fl_idx+1])begin
                    next_state <= IDLE; // there is a call at one upper floor
                    busy_state <= 1;
                end
                else next_state <= UP;
            end
            DOWN:begin
                if(call_floor[current_fl_idx-1])begin 
                    next_state <= IDLE; // there is a call at one lower floor
                    busy_state <= 1;
                end
                else next_state <= DOWN;
            end
            default: next_state <= IDLE;
        endcase
    end
    
    // ELEVATOR CALLING
    always @(posedge clk or negedge rst)begin
    if(~rst)begin
        call_floor <= 0;
        intermediate_state <= IDLE; // NEW
        led_outside_0 <= 0;
        led_outside_1 <= 0;
        led_outside_2 <= 0;
        led_outside_3 <= 0;
        led_outside_4 <= 0;
        led_inside_0 <= 0;
        led_inside_1 <= 0;
        led_inside_2 <= 0;
        led_inside_3 <= 0;
        led_inside_4 <= 0;
    end
    else if((floor_0_p || floor_0_d) && current_floor != FLOOR0 && ~call_floor[0] && intermediate_state != DOWN)begin // floor_0_p (lowermost floor)
        if(current_state != UP)begin
            intermediate_state <= UP;
            call_floor[0] <= 1;
            if(floor_0_p)led_outside_0 <= 1;
            else if (floor_0_d) led_inside_0 <= 1;
        end
        else begin
            call_floor[0] <= 0;
            if(floor_0_p)led_outside_0 <= 0;
            else if(floor_0_d) led_inside_0 <= 0;
        end
    end
    else if((floor_1_p || floor_1_d) && current_floor != FLOOR1 && ~call_floor[1])begin // floor_1_p
        if(current_state == IDLE)begin
            if((~direction_1 && intermediate_state!=UP) || (direction_1 && intermediate_state != DOWN))begin
                if(~direction_1) intermediate_state <= DOWN;
                else intermediate_state <= UP;
                call_floor[1] <= 1;
                if(floor_1_p)led_outside_1 <= 1;
                else if(floor_1_d) led_inside_1 <= 1;
            end
            else begin
                call_floor[1] <= 0;
                if(floor_1_p)led_outside_1 <= 0;
                else if(floor_1_d)led_inside_1 <= 0;
            end
        end
        else if(~direction_1)begin // go down
            if(current_state == UP)begin
                call_floor[1] <= 0;
                if(floor_1_p)led_outside_1 <= 0;
                else if(floor_1_d)led_inside_1 <= 0;
            end
            else begin
                call_floor[1] <= 1;
                if(floor_1_p)led_outside_1 <= 1;
                else if(floor_1_d) led_inside_1 <= 1;
            end
        end
        else if(direction_1)begin // go up
            if(FLOOR1 < current_floor)begin
                call_floor[1] <= 0;
                if(floor_1_p)led_outside_1 <= 0;
                else if(floor_1_d) led_inside_1 <= 0;
            end
            else begin
                call_floor[1] <= 1;
                if(floor_1_p)led_outside_1 <= 1;
                else if(floor_1_d) led_inside_1 <= 1;
            end
        end
    end
    else if((floor_2_p || floor_2_d) && current_floor != FLOOR2 && ~call_floor[2])begin // floor_2_p
        if(current_state == IDLE) begin
            if((direction_2 && intermediate_state!=DOWN)|| (~direction_2 && intermediate_state != UP))begin
                if(~direction_1) intermediate_state <= DOWN;
                else intermediate_state <= UP;
                call_floor[2] <= 1;
                if(floor_2_p)led_outside_2 <= 1;
                else if(floor_2_d) led_inside_2 <= 1;
            end
            else begin
                call_floor[2] <= 0;
                if(floor_2_p)led_outside_2 <= 0;
                else if(floor_2_d) led_inside_2 <= 0;
            end
        end
        else if(~direction_2)begin // go down
            if(FLOOR2 > current_floor)begin
                call_floor[2] <= 0;
                if(floor_2_p)led_outside_2 <= 0;
                else if(floor_2_d) led_inside_2 <= 0;
            end
            else if(current_state == UP)begin
                call_floor[2] <= 0;
                if(floor_2_p)led_outside_2 <= 0;
                else if(floor_2_d) led_inside_2 <= 0;
            end
            else begin
                call_floor[2] <= 1;
                if(floor_2_p)led_outside_2 <= 1;
                else if(floor_2_d) led_inside_2 <= 1;
            end
        end
        else if(direction_2)begin // go up
            if(FLOOR2 < current_floor)begin
                call_floor[2] <= 0;
                if(floor_2_p)led_outside_2 <= 0;
                else if(floor_3_d) led_inside_2 <= 0;
            end
            else if(current_state == DOWN)begin
                call_floor[2] <= 0;
                if(floor_2_p)led_outside_2 <= 0;
                else if(floor_3_d) led_inside_2 <= 0;
            end
            else begin
                call_floor[2] <= 1;
                if(floor_2_p)led_outside_2 <= 1;
                else if(floor_3_d) led_inside_2 <= 1;
            end
        end
    end
    else if((floor_3_p || floor_3_d) && current_floor != FLOOR3 && ~call_floor[3])begin// floor_3_p
        if(current_state == IDLE)begin
            if((direction_3 && intermediate_state!=DOWN) || (~direction_3 && intermediate_state!=UP))begin
                if(~direction_1) intermediate_state <= DOWN;
                else intermediate_state <= UP;
                call_floor[3] <= 1;
                if(floor_3_p)led_outside_3 <= 1;
                else if(floor_3_d) led_inside_3 <= 1;
            end
            else begin
                call_floor[3] <= 0;
                if(floor_3_p)led_outside_3 <= 0;
                else if(floor_3_d) led_inside_3 <= 0;
            end
        end
        else if(~direction_3)begin // go down
            if(FLOOR3 > current_floor)begin
                call_floor[3] <= 0;
                if(floor_3_p)led_outside_3 <= 0;
                else if(floor_3_d) led_inside_3 <= 0;
            end
            else begin
                call_floor[3] <= 1;
                if(floor_3_p)led_outside_3 <= 1;
                else if(floor_3_d) led_inside_3 <= 1;
            end
        end
        else if(direction_3)begin // go up
            if(current_state == DOWN)begin
                call_floor[3] <= 0;
                if(floor_3_p)led_outside_3 <= 0;
                else if(floor_3_d) led_inside_3 <= 0;
            end
            else begin
                call_floor[3] <= 1;
                if(floor_3_p)led_outside_3 <= 1;
                else if(floor_3_d) led_inside_3 <= 1;
            end
        end
    end
    else if((floor_4_p || floor_4_d) && current_floor != FLOOR4 && ~call_floor[4] && intermediate_state != UP)begin // floor_4_p (uppermost floor)
        if(current_state == IDLE)begin
            intermediate_state <= DOWN;
            call_floor[4] <= 1;
            if(floor_4_p)led_outside_4 <= 1;
            else if(floor_4_d) led_inside_4 <= 1;
        end
        else if(current_state != DOWN)begin
            call_floor[4] <= 1;
            if(floor_4_p)led_outside_4 <= 1;
            else if(floor_4_d) led_inside_4 <= 1;
        end
        else begin
            call_floor[4] <= 0;
            if(floor_4_p)led_outside_4 <= 0;
            else if(floor_4_d) led_inside_4 <= 0;
        end
    end
    else begin
        if(current_floor == FLOOR1)begin // floor is 1
            call_floor[1] <= 0;
            led_outside_1 <= 0;
            led_inside_1 <= 0;
        end
        else if(current_floor == FLOOR2)begin // floor is 2
            call_floor[2] <= 0;
            led_outside_2 <= 0;
            led_inside_2 <= 0;
        end
        else if(current_floor == FLOOR3)begin // floor is 3
            call_floor[3] <= 0;
            led_outside_3 <= 0;
            led_inside_3 <= 0;
        end
        else if(current_floor == FLOOR4)begin // floor is 4
            call_floor[4] <= 0;
            led_outside_4 <= 0;
            led_inside_4 <= 0;
        end
        else begin // floor is 0
            call_floor[0] <= 0;
            led_outside_0 <= 0;
            led_inside_0 <= 0;
        end
        if(~call_floor) intermediate_state <= IDLE;
        else begin end
    end
end

// Seven segment display
always @ (posedge clk or negedge rst) begin
	if(~rst) begin
		a <= 8'b11111111;
		b <= 8'b11111111;
		c <= 8'b11111111;
		d <= 8'b11111111;
		e <= 8'b11111111;
		f <= 8'b11111111;
		g <= 8'b11111111;
		p <= 8'b11111111;
	end
	else begin 
	case(current_floor)
	   FLOOR0: begin // FL-0 
	       case(current_state)
	        IDLE: begin //--Id     
	           a <= 8'b11110110;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11101010;
	           e <= 8'b11100010;
	           f <= 8'b11110010;
	           g <= 8'b11100111;
	           p <= 8'b11111111;
	       end
	       UP: begin //--UP
	           a <= 8'b11100110;
	           b <= 8'b11001110;
	           c <= 8'b11011110;
	           d <= 8'b11011010;
	           e <= 8'b11000010;
	           f <= 8'b11000010;
	           g <= 8'b11100111;
	           p <= 8'b11111111;
	       end 
	       DOWN: begin //--dO
	           a <= 8'b11100110;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11001010;
	           e <= 8'b11000010;
	           f <= 8'b11100010;
	           g <= 8'b11010111;
	           p <= 8'b11111111;
	       end
	       endcase
	   end
	   FLOOR1: begin // FL-1
	       case(current_state)
	        IDLE: begin //--Id
	           a <= 8'b11110111;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11101011;
	           e <= 8'b11100011;
	           f <= 8'b11110011;
	           g <= 8'b11100111;
	           p <= 8'b11111111;
	       end
	       UP: begin //--UP
	           a <= 8'b11100111;
	           b <= 8'b11001110;
	           c <= 8'b11011110;
	           d <= 8'b11011011;
	           e <= 8'b11000011;
	           f <= 8'b11000011;
	           g <= 8'b11100111;
	           p <= 8'b11111111;
	       end 
	       DOWN: begin //--dO
	           a <= 8'b11100111;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11001011;
	           e <= 8'b11000011;
	           f <= 8'b11100011;
	           g <= 8'b11010111;
	           p <= 8'b11111111;
	       end
	       endcase
	    end
	   FLOOR2: begin // FL-2
	        case(current_state)
	        IDLE: begin //--Id
	           a <= 8'b11110110;
	           b <= 8'b11001110;
	           c <= 8'b11001111;
	           d <= 8'b11101010;
	           e <= 8'b11100010;
	           f <= 8'b11110011;
	           g <= 8'b11100111;
	           p <= 8'b11111111;
	       end
	       UP: begin //--UP
	           a <= 8'b11100110;
	           b <= 8'b11001110;
	           c <= 8'b11011111;
	           d <= 8'b11011010;
	           e <= 8'b11000010;
	           f <= 8'b11000011;
	           g <= 8'b11100111;
	           p <= 8'b11111111;
	       end 
	       DOWN: begin //--dO
	           a <= 8'b11100110;
	           b <= 8'b11001110;
	           c <= 8'b11001111;
	           d <= 8'b11001010;
	           e <= 8'b11000010;
	           f <= 8'b11100011;
	           g <= 8'b11010111;
	           p <= 8'b11111111;
	       end
	      endcase
	   end
	   FLOOR3: begin  // FL-3
	    case(current_state)
	       IDLE: begin //--Id
	           a <= 8'b11110110;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11101010;
	           e <= 8'b11100011;
	           f <= 8'b11110011;
	           g <= 8'b11100110;
	           p <= 8'b11111111;
	       end
	       UP: begin //--UP
	           a <= 8'b11100110;
	           b <= 8'b11001110;
	           c <= 8'b11011110;
	           d <= 8'b11011010;
	           e <= 8'b11000011;
	           f <= 8'b11000011;
	           g <= 8'b11100110;
	           p <= 8'b11111111;
	       end 
	       DOWN: begin //--dO
	           a <= 8'b11100110;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11001010;
	           e <= 8'b11000011;
	           f <= 8'b11100011;
	           g <= 8'b11010110;
	           p <= 8'b11111111;
	       end
	       endcase
	   end
	   FLOOR4: begin // FL-4
	       case(current_state)
	        IDLE: begin //--Id
	           a <= 8'b11110111;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11101011;
	           e <= 8'b11100011;
	           f <= 8'b11110010;
	           g <= 8'b11100110;
	           p <= 8'b11111111;
	       end
	       UP: begin //--UP
	           a <= 8'b11100111;
	           b <= 8'b11001110;
	           c <= 8'b11011110;
	           d <= 8'b11011011;
	           e <= 8'b11000011;
	           f <= 8'b11000010;
	           g <= 8'b11100110;
	           p <= 8'b11111111;
	       end 
	       DOWN: begin //--dO
	           a <= 8'b11100111;
	           b <= 8'b11001110;
	           c <= 8'b11001110;
	           d <= 8'b11001011;
	           e <= 8'b11000011;
	           f <= 8'b11100010;
	           g <= 8'b11010110;
	           p <= 8'b11111111;
	       end
	       endcase
	end
	endcase
	end
end
endmodule