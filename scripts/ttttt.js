var ethers = require('ethers');
var crypto = require('crypto');
while (true) {

    var id = crypto.randomBytes(32).toString('hex');
    var privateKey = "0x" + id;
    var wallet = new ethers.Wallet(privateKey);

    if ((wallet.address.indexOf("88888888") !== -1)
        /*||
        (wallet.address.substr(wallet.address.length - 6, 6)) === "888888"*/) {
        console.log("查找完成");
        console.log("私钥:", privateKey);
        console.log("公钥: " + wallet.address);
    }
    //console.log("公钥: " + wallet.address);
    //console.log("公钥: " + (wallet.address.substr(wallet.address.length - 6, 6)));

}