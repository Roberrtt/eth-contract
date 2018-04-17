// Allows us to use ES6 in our migrations and tests.
var HDWalletProvider = require("truffle-hdwallet-provider"); 
var infura_apikey = "r9Qjyy8UJtlT7UWNJCCz"; 
var mnemonic = "pond theme test bracket someone jewel core educate seek buzz wedding casual"; 

require('babel-register')

// module.exports = {
//   networks: {
//     development: {
//       // host: '127.0.0.1',
//       // port: 8545,
//       // network_id: '*' // Match any network id
//       host: 'localhost',
//       port: '8545',
//       network_id: '3', // Match any network id  
//       from: "0x9c15b2594783619c6ea68a46e1a7e350512c14f4",
//       gas: 1000000,
//       gasPrice: 10000000000,
//     }
//   }
// }
module.exports = { 
  networks: { 
    localhost: { 
      host: "localhost", 
      port: 8545, 
      network_id: "*" 
    }, 
    "main": {
      network_id: 1,
      gas: 500000
    },
    ropsten: {   // 0xAf588a130396276F496bA0EBE24e85711B43D2aA
      // host: "localhost", 
      // port: 8545, 
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey), 
      network_id: "3",
      gas: 4612388
    } 
  } 
};