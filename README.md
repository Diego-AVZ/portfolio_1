# AVZ.Tech Portfolio Project: **FlowFi**

## What is **FlowFi**?
FlowFi is an all-in-one DeFi protocol designed to showcase advanced Solidity development skills. This protocol enables users to manage their decentralized finance (DeFi) activities seamlessly through a single contract. The primary objective is to simplify DeFi by integrating multiple protocols and strategies into a unified DeFi Hub with an exceptional user experience (UX).

> FlowFi is a testament to @AVZ.Tech's expertise in DeFi protocols, Solidity development, and data management capabilities.

### **Highlights**  
- **Unified Management:** Streamline DeFi operations in one place.  
- **Simplified Strategies:** Access multiple protocols with ease.  
- **Best-in-Class UX:** Focus on delivering a seamless and intuitive user experience.  

## **Architecture**
I design **modular structures** for my smart contract projects to ensure:  
- **Scalability:** Easily adaptable for future growth.  
- **Legibility:** Clear and maintainable codebase.  
- **Upgradeability:** Seamless integration of updates without disrupting the system.  

The architecture follows this structure:  

### **1. Main**  
- Serves as the primary entry point for **frontend developers**, simplifying their work.  
- Allows interaction with the entire protocol using a single ABI.  
- Centralizes function calls, delegating execution to the appropriate contracts.  

### **2. Executors**  
- Contains the **core logic** of the protocol.  
- Handles all computations and data modifications.  
- Designed for modularity, ensuring clear separation of responsibilities.  

### **3. Storage**  
- Dedicated to storing the protocol's most critical data.  
- Ensures data integrity and protects it from updates to other contracts.  
- Acts as the foundation of the protocol's **data persistence layer**.  
  

## Project Structure
```ml
|-- src
|   |-- interfaces
|   |   |-- IERC20.sol
```

