`timescale 1ns / 1ps

module licznik_up_down(
    input clk,            
    input sensorA,        
    input sensorB,        
    input btnC,           
    output reg [6:0] seg, 
    output reg [3:0] an,  
    output wire led_limit,
    output wire led_sec,
    output wire led_A,    // <--- DODANE: Dioda diagnostyczna czujnika A (LD0)
    output wire led_B     // <--- DODANE: Dioda diagnostyczna czujnika B (LD1)
);
// =========================================================
// 1. Dzielnik czêstotliwoœci
// =========================================================
reg [19:0] clkdiv = 0;
always @(posedge clk) begin
    clkdiv <= clkdiv + 1;
end
wire [1:0] digit_sel = clkdiv[18:17]; 
wire slow_clk = clkdiv[19];           

// =========================================================
// ZMIENNE DO LOGIKI
// =========================================================
reg [6:0] timer_tick = 0;
reg blink_state = 0;
reg bit_entered = 0;
reg [3:0] code_reg = 0;
reg override_mode = 0; 

// Debouncing czujników i przycisku
reg sA_reg, sB_reg, btnC_reg;
reg btnC_prev;

// Zmienne Maszyny Stanów (FSM)
reg [2:0] gate_state = 0;
reg enter_pulse = 0;
reg exit_pulse = 0;

// Rejestry BCD
reg [3:0] dig0 = 0; reg [3:0] dig1 = 0; reg [3:0] dig2 = 0; reg [3:0] dig3 = 0; 

wire is_full = (dig3 > 0) || (dig2 > 0) || (dig1 > 1) || (dig1 == 1 && dig0 >= 3);
wire block_entry = is_full && !override_mode;

assign led_limit = is_full;
assign led_sec = override_mode ? 1'b1 : (is_full ? blink_state : 1'b0);

// =========================================================
// 2. G£ÓWNY BLOK LOGIKI (~95 razy na sekundê)
// =========================================================
always @(posedge slow_clk) begin
    
    // --- A. Odczyt stanów
    sA_reg <= sensorA; 
    sB_reg <= sensorB; 
    
    btnC_reg <= btnC;
    btnC_prev <= btnC_reg;

    // --- B. Zegar 1 Hz (Kod VIP) ---
    if (timer_tick >= 95) begin
        timer_tick <= 0;
        code_reg <= {code_reg[2:0], bit_entered}; 
        bit_entered <= 0;                         
    end else begin
        timer_tick <= timer_tick + 1;
    end
    
    blink_state <= (timer_tick < 48); 

    if (btnC_reg & ~btnC_prev) bit_entered <= 1;

    if (code_reg == 4'b1101) begin
        override_mode <= 1;  
        code_reg <= 4'b0000; 
    end

    // --- C. MASZYNA STANÓW (Kierunek Ruchu) ---
    enter_pulse <= 0; 
    exit_pulse <= 0;
    
    case(gate_state)
        // 00: Pusta bramka (Czekamy na ruch)
        0: begin 
            if (sA_reg == 1 && sB_reg == 0) gate_state <= 1;      // Ktoœ wchodzi od A (10)
            else if (sA_reg == 0 && sB_reg == 1) gate_state <= 4; // Ktoœ wychodzi od B (01)
        end
        
        // --- SEKWENCJA WEJŒCIA (+1) ---
        1: begin // Stan 10
            if (sA_reg == 1 && sB_reg == 1) gate_state <= 2;      // Zas³oni³ oba (11)
            else if (sA_reg == 0 && sB_reg == 0) gate_state <= 0; // Fa³szywy alarm (Cofn¹³ siê)
        end
        2: begin // Stan 11
            if (sA_reg == 0 && sB_reg == 1) gate_state <= 3;      // Ods³oni³ A, wci¹¿ zas³ania B (01)
            else if (sA_reg == 1 && sB_reg == 0) gate_state <= 1; // Cofn¹³ siê do A (10)
            else if (sA_reg == 0 && sB_reg == 0) gate_state <= 0; // B³¹d/Anulowanie
        end
        3: begin // Stan 01
            if (sA_reg == 0 && sB_reg == 0) begin                 // Ca³kowicie opuœci³ bramkê! (00)
                gate_state <= 0;
                enter_pulse <= 1;                                 // WYZWÓL IMPULS DODAWANIA
            end
            else if (sA_reg == 1 && sB_reg == 1) gate_state <= 2; // Cofn¹³ siê w œrodek bramki
        end
        
        // --- SEKWENCJA WYJŒCIA (-1) ---
        4: begin // Stan 01
            if (sA_reg == 1 && sB_reg == 1) gate_state <= 5;      // Zas³oni³ oba (11)
            else if (sA_reg == 0 && sB_reg == 0) gate_state <= 0; // Fa³szywy alarm
        end
        5: begin // Stan 11
            if (sA_reg == 1 && sB_reg == 0) gate_state <= 6;      // Ods³oni³ B, wci¹¿ zas³ania A (10)
            else if (sA_reg == 0 && sB_reg == 1) gate_state <= 4; // Cofn¹³ siê do B (01)
            else if (sA_reg == 0 && sB_reg == 0) gate_state <= 0; 
        end
        6: begin // Stan 10
            if (sA_reg == 0 && sB_reg == 0) begin                 // Ca³kowicie opuœci³ bramkê na zewn¹trz! (00)
                gate_state <= 0;
                exit_pulse <= 1;                                  // WYZWÓL IMPULS ODEJMOWANIA
            end
            else if (sA_reg == 1 && sB_reg == 1) gate_state <= 5; 
        end
        
        default: gate_state <= 0;
    endcase

    // --- D. Licznik BCD ---
    if (enter_pulse) begin
        if (!block_entry) begin
            if (override_mode) override_mode <= 0; 
            
            if (dig0 == 9) begin
                dig0 <= 0;
                if (dig1 == 9) begin
                    dig1 <= 0;
                    if (dig2 == 9) begin
                        dig2 <= 0;
                        if (dig3 == 9) dig3 <= 0;
                        else dig3 <= dig3 + 1;
                    end else dig2 <= dig2 + 1;
                end else dig1 <= dig1 + 1;
            end else dig0 <= dig0 + 1;
        end
    end 
    else if (exit_pulse) begin
        if (!(dig3 == 0 && dig2 == 0 && dig1 == 0 && dig0 == 0)) begin
            if (dig0 == 0) begin
                dig0 <= 9;
                if (dig1 == 0) begin
                    dig1 <= 9;
                    if (dig2 == 0) begin
                        dig2 <= 9;
                        if (dig3 == 0) dig3 <= 9;
                        else dig3 <= dig3 - 1;
                    end else dig2 <= dig2 - 1;
                end else dig1 <= dig1 - 1;
            end else dig0 <= dig0 - 1;
        end
    end
end

// =========================================================
// 3. WYŒWIETLACZ 7-SEGMENTOWY
// =========================================================
reg [3:0] current_digit;
always @(*) begin
    case(digit_sel)
        2'b00: begin an = 4'b1110; current_digit = dig0; end 
        2'b01: begin an = 4'b1101; current_digit = dig1; end 
        2'b10: begin an = 4'b1011; current_digit = dig2; end 
        2'b11: begin an = 4'b0111; current_digit = dig3; end 
    endcase
end

always @(*) begin
    case(current_digit)
        4'h0: seg = 7'b1000000;
        4'h1: seg = 7'b1111001;
        4'h2: seg = 7'b0100100;
        4'h3: seg = 7'b0110000;
        4'h4: seg = 7'b0011001;
        4'h5: seg = 7'b0010010;
        4'h6: seg = 7'b0000010;
        4'h7: seg = 7'b1111000;
        4'h8: seg = 7'b0000000;
        4'h9: seg = 7'b0010000;
        default: seg = 7'b1111111; 
    endcase
end
// Diody diagnostyczne - pokazuj¹, co DOK£ADNIE widzi FSM
    assign led_A = sA_reg;
    assign led_B = sB_reg;

endmodule