This project simulates a 4G evolved packet core network (EPC) 

Composed of :
  1. Mobile Mobility Platform (MME) 
      - handles user authorization
      - habdles user credit balance before making connections
      - tracks user location (updates position)
  2. Service Gateway (SGW)
      - holds the (tcp) connection with the eNodeB
      - forwards packages from eNodeB to PGW
      - forwards messages from PGW to eNodeB tower
  3. Package Gateway (PGW)
      - keeps the connection between epc and the internet
      - handles bidirectional communication between SGW and internet
  4. EPC Client
      - simulates a connected client(handset) through
      a radiotower (eutran) that exchanges fata with the EPC 


Each component is basically a erlang application that might run or not in a distributed mode.
Currently as a database Mnesia and ETS are used.
  
