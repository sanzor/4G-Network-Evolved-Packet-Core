This project simulates a 4G network evolved packet core (EPC) 

Composed of :
  1. Mobile Mobility Platform (MME) 
      - handles user authentication and authorization
      - handles user credit balance
      - connected clients use it to update their location (updates position)
  2. Service Gateway (SGW)
      - holds the (tcp) connection with the connected client
      - forwards packages from connected client  to PGW
      - forwards messages from PGW to connected client
  3. Package Gateway (PGW)
      - keeps the connection between epc and the internet
      - handles bidirectional communication between SGW and internet
  4. EPC Client
      - simulates a connected client(handset) through
      a radiotower (eutran) that exchanges fata with the EPC 


Each component is basically an erlang application that might run or not in a distributed mode.
Currently a Mnesia database and ETS are use for state tracking of connected clients/sessions.
  
