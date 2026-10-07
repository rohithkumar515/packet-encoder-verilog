module packet_encoder(input clk,reset_n,
                      input [7:0]payload_data_in,
                      input ip_valid,
                      input [7:0]destination_addr,
                      input [7:0]payload_size,
                      output reg [7:0] packet_out,
                      output reg packet_valid);
                      
                      //declaring the states
                      parameter idle= 3'd0;
                      parameter header_addr=3'd1;
                      parameter header_size=3'd2;
                      parameter payload=3'd3;
                      parameter parity=3'd4;
                      
                 reg[2:0] p,n;//p is for present state and n is for next state
                 
                 reg [7:0]dest_reg; //it is used to store the destination address
                 reg [7:0]size_reg;// it stores size of payload
                 reg [7:0]count;// used to count the payload
                 reg parity_reg; //stores parity bit
                
                
                // This always block helps us convert next state as present state 
                 always @(posedge clk or negedge reset_n)begin
                 if(!reset_n)begin
                 p<=idle;
                 n<=idle;
                 end
                 else
                 p<=n;
                 end
             
            //this always block is used to jump into the next state     
            always @(*)begin
            case(p)
            idle: if(ip_valid) //if ip is valid the it should go to the next state of header_addr
                  n=header_addr;
                  else
                  n=idle;
                  
            header_addr: n=header_size; //automatically jump into the addr to size
            
            header_size: if(size_reg==0)//in size state if the size of pay load is '0' it should jump in to the parity state
                         n=parity;
                         else //if the size of payload is not 0 then it should jump into the payload state
                         n=payload;
            
            payload: if(ip_valid) begin
                        if(count==size_reg-1'b1)
                        n=parity;
                        else
                        n=payload;
                        end
                     else
                     n=payload;
                     
                     
            parity: n=idle;
            
            default: n=idle;
            endcase
            end
            
            
            // now we use a always block how encoder works at each posedge of clk and how parity is generated
            always @(posedge clk or negedge reset_n)
            begin
                if (!reset_n)begin
                dest_reg<=0;
                size_reg<=0;
                count<=0;
                parity_reg<=0;
                end
                
                else if(p==idle && ip_valid)
                begin
                dest_reg<=destination_addr;
                size_reg<=payload_size;
                count<=0;
                parity_reg<=^destination_addr;
                end
                
                else if(p==header_size)
                parity_reg<= parity_reg ^ ^payload_size;
                
                else if(p==payload && ip_valid)
                begin
                count<=count+1;
                parity_reg<=parity_reg ^ ^payload_data_in;
                end
                
            end 
            
            always @(*) begin
            case(p)
                idle: begin packet_out=8'd0;
                      packet_valid=1'b0; end
                      
                header_addr: begin packet_out=dest_reg;
                                   packet_valid=1'b1; end 
                
                header_size: begin packet_out= size_reg;
                                   packet_valid=1'b1; end
                
                payload:  if(ip_valid)begin 
                                packet_out= payload_data_in;
                                packet_valid=1'b1; 
                            end
                            else begin 
                                packet_out=8'd0;
                                packet_valid=1'b0; 
                            end
                            
                                
                parity: begin packet_out={7'b0,parity_reg};
                              packet_valid=1'b1; end
                              
                              
               default: begin packet_out=8'd0;
                              packet_valid=1'b0; end  
            endcase
            end
endmodule
