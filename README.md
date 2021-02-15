# ERC721 token based supply chain	traceability 

## Authors: SevgicanV, GorkemA, DenizM

## Instructor: Can Ozturan

This repository contains the group project for ETM555 Design Of Information Systems class.


One can read the report from [here](https://github.com/d8niz/etm555-hw/reports).

### TECH STACK

- Solidity ^0.0.7
- Truffle v5.1.65
- Node v15.4.0


### DEPENDENCIES

- truffle [npm](https://www.npmjs.com/package/truffle)

- installation: 

```bash
npm i -g truffle
```

- @openzeppelin/contracts [npm](https://www.npmjs.com/package/openzeppelin-solidity)

- installation:

```bash
npm i @openzeppelin/contracts@solc-0.7 -s
```


### RUN

- Go to project root folder:

- Install dependencies via npm: 

```bash
npm i 
```

- Start the truffle development server (which is a test-rpc a.k.a ganache-cli anyways) 

```bash
truffle develop
```

- And start playing around with the contracts after migration, how to interact with your contracts is [here](https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts)


- Alternatively one can start the truffle console (for which you have to configure a development server in ./truffle-config.js)
```bash
truffle console
```

- More details for quick start on  [truffle](https://www.trufflesuite.com/)



