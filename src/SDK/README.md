# **SDK Documentation**

## Why Implement This Project in Your Protocol?

- **Simplifies DeFi:** Streamlines interaction with decentralized finance protocols.
- **Join a Huge DeFi Ecosystem:** Expand your protocol’s reach and interoperability.
- **Protect Your Users:** Enable users to interact with multiple DeFi protocols securely through a personal `WalletContract`.

---

## How to Implement This Project in Your Protocol

### Step 1: Connect Your Frontend

- Integrate your frontend with the `MainContract` using the ABI file `abiMainContract.json`.
- Use the following contract address:
 `0x0001234abc`

### Step 2: Customize Your Contract

- Create and modify a `CustomFunction` contract.
- Follow the instructions in the **How to Customize Your Contract?** section of this guide.

### Step 3: Build Data with `buildData()`

- Use the JavaScript/TypeScript function `buildData()` to construct the required data payload.
- Parameters:
- `bytes _functionSelector`
- `uint256[] _paramsTypes`
- `struct _params`

### Step 4: Execute DeFi Actions

- Call the `MainContract.defiAction()` function with the following parameters:
- `bytes _data`
- `address user`

---

For further details, refer to the complete developer guide or contact the support team.