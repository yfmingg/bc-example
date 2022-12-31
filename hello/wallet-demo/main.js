var bip39 = require('bip39')
// 生成助记词
var mnemonic = bip39.generateMnemonic()
console.log(mnemonic)