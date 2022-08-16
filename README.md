# Kiva Live
https://quouch.com/kivalive/ (randomized/simulated activity, not "live")
### Project goal 
* Create a real-time visualization of microlending activity on the Kiva website
### Implementation details
* Implemented using PHP, MySQL, Redis, Three.js
* Event-based system: each new loan is posted using a pub/sub model to all clients currently "listening" to the loan feed
* Clients can receive new loan postings and render them on a 3D world map
* Loans are visuzlized as paths between the lender (origin) and borrower (destination)
* This code can also be used to "replay" sequences of past loans
