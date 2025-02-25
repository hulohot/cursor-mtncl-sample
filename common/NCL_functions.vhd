-- to be used in testbenches
-- not to be synthesized


Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ncl_signals.all;

package functions is

function is_null(s: DUAL_RAIL_LOGIC_VECTOR) return BOOLEAN;
function is_data(s: DUAL_RAIL_LOGIC_VECTOR) return BOOLEAN;
function is_null(s: DUAL_RAIL_LOGIC) return BOOLEAN;
function is_data(s: DUAL_RAIL_LOGIC) return BOOLEAN;

function is_null(s: QUAD_RAIL_LOGIC_VECTOR) return BOOLEAN;
function is_data(s: QUAD_RAIL_LOGIC_VECTOR) return BOOLEAN;
function is_null(s: QUAD_RAIL_LOGIC) return BOOLEAN;
function is_data(s: QUAD_RAIL_LOGIC) return BOOLEAN;

function to_DR(s:std_logic) return DUAL_RAIL_LOGIC;
function to_DR(s:std_logic_vector) return DUAL_RAIL_LOGIC_VECTOR;

function Int_to_DR(int: integer; size: integer) return DUAL_RAIL_LOGIC_VECTOR;  ---added by Liang Men

function to_SL(d:DUAL_RAIL_LOGIC) return std_logic;
function to_SL(d:DUAL_RAIL_LOGIC_VECTOR) return std_logic_vector;

function to_SL(q:QUAD_RAIL_LOGIC) return  std_logic_vector;
function to_SL(q:QUAD_RAIL_LOGIC_VECTOR) return std_logic_vector;

function to_DR(q:QUAD_RAIL_LOGIC) return DUAL_RAIL_LOGIC_VECTOR;
function to_DR(q:QUAD_RAIL_LOGIC_VECTOR) return DUAL_RAIL_LOGIC_VECTOR;

function to_QR(s: std_logic_vector) return QUAD_RAIL_LOGIC;
function to_QR(d:DUAL_RAIL_LOGIC_VECTOR) return QUAD_RAIL_LOGIC;

function to_QR(s:std_logic_vector) return QUAD_RAIL_LOGIC_VECTOR;
function to_QR(d:DUAL_RAIL_LOGIC_VECTOR) return QUAD_RAIL_LOGIC_VECTOR;

end functions;

package body functions is

function is_null(s: DUAL_RAIL_LOGIC_VECTOR) return BOOLEAN is
begin
    for i in 0 to s'length - 1 loop
	if s(i).rail0 = '0' and s(i).rail1 = '0' then
		null;
	else
		return FALSE;
	end if;
    end loop;
    return TRUE;
end is_null;

function is_data(s: DUAL_RAIL_LOGIC_VECTOR) return BOOLEAN is
begin
    for i in 0 to s'length - 1 loop
        if s(i).rail0 = '1' or s(i).rail1 = '1' then
                null;
        else
                return FALSE;
        end if;
    end loop;
    return TRUE;
end is_data;

function is_null(s: DUAL_RAIL_LOGIC) return BOOLEAN is
begin
        if s.rail0 = '0' and s.rail1 = '0' then
                return TRUE;
        else
                return FALSE;
        end if;
end is_null;

function is_data(s: DUAL_RAIL_LOGIC) return BOOLEAN is
begin
        if s.rail0 = '1' or s.rail1 = '1' then
                return TRUE;
        else
                return FALSE;
        end if;
end is_data;

function is_null(s: QUAD_RAIL_LOGIC_VECTOR) return BOOLEAN is
begin
    for i in 0 to s'length - 1 loop
	if s(i).rail0 = '0' and s(i).rail1 = '0' and s(i).rail2 = '0' and s(i).rail3 = '0' then
		null;
	else
		return FALSE;
	end if;
    end loop;
    return TRUE;
end is_null;

function is_data(s: QUAD_RAIL_LOGIC_VECTOR) return BOOLEAN is
begin
    for i in 0 to s'length - 1 loop
        if s(i).rail0 = '1' or s(i).rail1 = '1' or s(i).rail2 = '1' or s(i).rail3 = '1' then
                null;
        else
                return FALSE;
        end if;
    end loop;
    return TRUE;
end is_data;

function is_null(s: QUAD_RAIL_LOGIC) return BOOLEAN is
begin
        if s.rail0 = '0' and s.rail1 = '0' and s.rail2 = '0' and s.rail3 = '0' then
                return TRUE;
        else
                return FALSE;
        end if;
end is_null;

function is_data(s: QUAD_RAIL_LOGIC) return BOOLEAN is
begin
        if s.rail0 = '1' or s.rail1 = '1' or s.rail2 = '1' or s.rail3 = '1' then
                return TRUE;
        else
                return FALSE;
        end if;
end is_data;

function to_DR(s: std_logic) return DUAL_RAIL_LOGIC is
variable d:DUAL_RAIL_LOGIC;
begin 
        if s='0' then
	    d.rail0:='1';
	    d.rail1:='0';
	 return d;
	
	else 
	    d.rail0:='0';
	    d.rail1:='1';
	 return d;  
	end if;
end to_DR;	 

function to_DR(s: std_logic_vector) return DUAL_RAIL_LOGIC_VECTOR is
variable d:DUAL_RAIL_LOGIC_VECTOR(s'length-1 downto 0);
begin
        for i in 0 to s'length - 1 loop
	
	    if s(i)='0' then
	           d(i).rail0:='1';
	           d(i).rail1:='0';
	    else 
	           d(i).rail0:='0';
	           d(i).rail1:='1';
	    
	    end if; 
	end loop;     
  return d;
end to_DR;  

------------------- Change integer to Dual_rail_logic_vector--------------------------
function Int_to_DR(int: integer; size: integer) return DUAL_RAIL_LOGIC_VECTOR is
variable Int_to_Std: std_logic_vector(size-1 downto 0);
variable Std_to_Rail: DUAL_RAIL_LOGIC_VECTOR(size-1 downto 0);
begin

            Int_to_Std :=  std_logic_vector(to_signed(int, size));
	    Std_to_Rail := to_DR(Int_to_Std);
    return Std_to_Rail;
end Int_to_DR;

-----------------------Revised by Liang Men @ 03/30/2013------------------------------    


function to_SL(d: DUAL_RAIL_LOGIC) return std_logic is
variable s:std_logic;
begin
        s:=d.rail1;
	return s;
end to_SL; 	
	  
function to_SL(d: DUAL_RAIL_LOGIC_VECTOR) return std_logic_vector is	        
variable s:std_logic_vector(d'length-1 downto 0);
begin
        for i in 0 to d'length - 1 loop
	        s(i):=d(i).rail1;
	end loop;
     return s;
end to_SL;     		

function to_SL(q: QUAD_RAIL_LOGIC) return  std_logic_vector is
variable s:std_logic_vector(1 downto 0);
begin
         if q.rail0='1' then
	 
	   s(1):='0';
	   s(0):='0';
	   
	 elsif q.rail1='1' then
	 
	    s(1):='0';
	    s(0):='1';
	    
	 elsif q.rail2='1' then
	 
	    s(1):='1';
	    s(0):='0';
	    
	 else     
	         
	    s(1):='1';
	    s(0):='1';
	    
	 end if;
  return s;
end to_SL;

function to_SL(q: QUAD_RAIL_LOGIC_VECTOR) return std_logic_vector is
variable s:std_logic_vector(2*q'length-1 downto 0);
begin
         for i in 0 to q'length-1 loop
	 
	    if q(i).rail0='1' then
	    
	       s(2*i):='0';
	       s(2*i+1):='0';
	       
	    elsif q(i).rail1='1' then
	    
	       s(2*i):='1';
	       s(2*i+1):='0';
	       
	    elsif q(i).rail2='1' then
	    
	       s(2*i):='0';
	       s(2*i+1):='1';
	       
	    else          
	       
	       s(2*i):='1';
	       s(2*i+1):='1';
	       
	    end if;
	 end loop;
   return s;
end to_SL; 

function to_DR(q:QUAD_RAIL_LOGIC) return DUAL_RAIL_LOGIC_VECTOR is
variable d:DUAL_RAIL_LOGIC_VECTOR(1 downto 0);
begin
         if q.rail0='1' then
	 
	      d(1).rail0:='1';  d(1).rail1:='0';
	      d(0).rail0:='1';  d(0).rail1:='0';
	      
	 elsif q.rail1='1' then
	 
	      d(1).rail0:='1';  d(1).rail1:='0';
	      d(0).rail0:='0';  d(0).rail1:='1';
	      	 
	 elsif q.rail2='1' then
	 
	      d(1).rail0:='0';  d(1).rail1:='1';
	      d(0).rail0:='1';  d(0).rail1:='0'; 
	       
	 else
	 
	      d(1).rail0:='0';  d(1).rail1:='1';
	      d(0).rail0:='0';  d(0).rail1:='1'; 
	       
	 end if;
  return d;
end to_DR;  	          

function to_DR(q: QUAD_RAIL_LOGIC_VECTOR) return DUAL_RAIL_LOGIC_VECTOR is
variable d:DUAL_RAIL_LOGIC_VECTOR(2*q'length-1 downto 0);
begin
         for i in 0 to q'length-1 loop
  	    if q(i).rail0='1' then
	    
	      d(2*i+1).rail0:='1';  d(2*i+1).rail1:='0';
	      d(2*i).rail0:='1';    d(2*i).rail1:='0';
	      
	    elsif q(i).rail1='1' then
	    
	      d(2*i+1).rail0:='1';  d(2*i+1).rail1:='0';
	      d(2*i).rail0:='0';    d(2*i).rail1:='1';	
	       
	    elsif q(i).rail2='1' then
	    
	      d(2*i+1).rail0:='0';  d(2*i+1).rail1:='1';
	      d(2*i).rail0:='1';    d(2*i).rail1:='0';  
	      
	    else
	    
	      d(2*i+1).rail0:='0';  d(2*i+1).rail1:='1';
	      d(2*i).rail0:='0';    d(2*i).rail1:='1'; 
	       
	    end if;
	  end loop;  
   return d;
end to_DR;

function to_QR(s: std_logic_vector) return QUAD_RAIL_LOGIC is
variable q : QUAD_RAIL_LOGIC;
begin 
              if (s(1)='0' and s(0)='0') then 
	       
	           q.rail0:='1';  q.rail1:='0';  q.rail2:='0';  q.rail3:='0';
		   
	      elsif (s(1)='0' and s(0)='1') then 
	      
	           q.rail0:='0';  q.rail1:='1';  q.rail2:='0';  q.rail3:='0';
		   	    	  
	      elsif (s(1)='1' and s(0)='0') then 
	      
	           q.rail0:='0';  q.rail1:='0';  q.rail2:='1';  q.rail3:='0';
		   
	      elsif (s(1)='1' and s(0)='1') then
	       
	           q.rail0:='0';  q.rail1:='0';  q.rail2:='0';  q.rail3:='1';
		   	
	      end if;
	return q; 
 end to_QR;	      
	           
function to_QR(s: std_logic_vector) return QUAD_RAIL_LOGIC_VECTOR is
variable q : QUAD_RAIL_LOGIC_VECTOR((s'length/2)-1 downto 0);
begin
         for i in 0 to q'length-1 loop
	       if (s(2*i+1)='0' and s(2*i)='0') then 
	       
	           q(i).rail0:='1';  q(i).rail1:='0';  q(i).rail2:='0';  q(i).rail3:='0';
		   
	      elsif (s(2*i+1)='0' and s(2*i)='1') then 
	      
	           q(i).rail0:='0';  q(i).rail1:='1';  q(i).rail2:='0';  q(i).rail3:='0';
		   	    	  
	      elsif (s(2*i+1)='1' and s(2*i)='0') then 
	      
	           q(i).rail0:='0';  q(i).rail1:='0';  q(i).rail2:='1';  q(i).rail3:='0';
		   
	      elsif (s(2*i+1)='1' and s(2*i)='1') then
	       
	           q(i).rail0:='0';  q(i).rail1:='0';  q(i).rail2:='0';  q(i).rail3:='1';
		   	
	      end if;
	  end loop;
  return q;
end to_QR; 

function to_QR(d: DUAL_RAIL_LOGIC_VECTOR) return QUAD_RAIL_LOGIC is
variable q : QUAD_RAIL_LOGIC;
begin
              if (d(1).rail1='0' and d(0).rail1='0') then 
	      
	           q.rail0:='1';  q.rail1:='0';  q.rail2:='0';  q.rail3:='0';
		   
	      elsif (d(1).rail1='0' and d(0).rail1='1') then 
	      
	           q.rail0:='0';  q.rail1:='1';  q.rail2:='0';  q.rail3:='0';
		   	    	  
	      elsif (d(1).rail1='1' and d(0).rail1='0') then 
	      
	           q.rail0:='0';  q.rail1:='0';  q.rail2:='1';  q.rail3:='0';
		   
	      elsif (d(1).rail1='1' and d(0).rail1='1') then 
	      
	           q.rail0:='0';  q.rail1:='0';  q.rail2:='0';  q.rail3:='1';
		   	
	      end if;
     return q;
 end to_QR;     	      

function to_QR(d: DUAL_RAIL_LOGIC_VECTOR) return QUAD_RAIL_LOGIC_VECTOR is
variable q:QUAD_RAIL_LOGIC_VECTOR((d'length/2)-1 downto 0);
begin
         for i in 0 to q'length-1 loop
	      if (d(2*i+1).rail1='0' and d(2*i).rail1='0') then 
	      
	           q(i).rail0:='1';  q(i).rail1:='0';  q(i).rail2:='0';  q(i).rail3:='0';
		   
	      elsif (d(2*i+1).rail1='0' and d(2*i).rail1='1') then 
	      
	           q(i).rail0:='0';  q(i).rail1:='1';  q(i).rail2:='0';  q(i).rail3:='0';
		   	    	  
	      elsif (d(2*i+1).rail1='1' and d(2*i).rail1='0') then 
	      
	           q(i).rail0:='0';  q(i).rail1:='0';  q(i).rail2:='1';  q(i).rail3:='0';
		   
	      elsif (d(2*i+1).rail1='1' and d(2*i).rail1='1') then 
	      
	           q(i).rail0:='0';  q(i).rail1:='0';  q(i).rail2:='0';  q(i).rail3:='1';
		   	
	      end if;
	  end loop;
  return q;
end to_QR;  	      	      

end functions;

