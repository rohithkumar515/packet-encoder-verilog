module packet_encoder_tb();
    reg clk;
    reg reset_n;

    reg [7:0] payload_data_in;
    reg       ip_valid;
    reg [7:0] destination_addr;
    reg [7:0] payload_size;

    wire [7:0] packet_out;
    wire       packet_valid;
    
    packet_encoder uut (
            .clk(clk),
            .reset_n(reset_n),
            .payload_data_in(payload_data_in),
            .ip_valid(ip_valid),
            .destination_addr(destination_addr),
            .payload_size(payload_size),
            .packet_out(packet_out),
            .packet_valid(packet_valid)
        );
        
        
        always #5 clk=~clk;
        initial begin
        clk=0;reset_n=0; ip_valid=0; payload_data_in = 8'd0;
        destination_addr = 8'd0; payload_size = 8'd0;
        
        @(posedge clk)reset_n=1; ip_valid=1'b1; destination_addr = 8'hAA;
                payload_size = 8'd3; 
       #30 @(posedge clk)payload_data_in=8'h11;     
        
        @(posedge clk) payload_data_in=8'h22;
        
        @(posedge clk) payload_data_in=8'h33;
        
        # 30 $stop;
        end
endmodule
