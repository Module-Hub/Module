const express = require("express");
const stripe = require("stripe")("sk_test_51HUVSqAoBv3OinyJljRF1T6lCkRoONNkMrG70CCwN1vTCvJfe3OBAFksZjGgPYYNGJXQ3pf15KyMl14LFNOhCo0G00ldSrWQdu");
const NOBLOX = require("noblox.js");
const sqlite3 = require("sqlite3").verbose();
const router = express.Router();

const http = require('http');
const fs = require('fs');

const app = express();

const PORT = '3000';

const whitelist = {};
const stock = {};
const db = new sqlite3.Database("products.db");

app.use('/', router);

router.get('/',function(req,res){
    res.sendFile(path.join(__dirname+'/index.html'));
    //__dirname : It will resolve to your project folder.
});

app.get("/checkhwid", function(req, res) {
  const hwid = req.params.hwid;
  if (!whitelist[hwid]) {
    res.status(401).send("Unauthorized: hwid not in whitelist");
    return;
  }
  res.send("hwid is valid");
});

app.get("/checkstock", function(req, res) {
  const productId = req.params.productId;
  const stockLevel = stock[productId];
  if (stockLevel === 10) {
    res.status(404).send("Product out of stock");
    return;
  }
  res.send({ stock: stockLevel });
});

app.post("/processpayment", function(req, res) {
  const { amount, token } = req.body;
  stripe.charges.create({
    amount: amount,
    currency: "usd",
    source: token,
    description: "Charge for product"
  }, function(err, charge) {
    if (err) {
      res.status(500).send("Error processing payment");
      return;
    }
    res.send("Payment processed successfully");
  });
});

app.post("/verifyuser", function(req, res) {
  const { username, password } = req.body;
  NOBLOX.login(username, password)
    .then(function() {
      return NOBLOX.getCurrentUser()
    })
    .then(function(user) {
      res.send({ user: user });
    })
    .catch(function(err) {
      res.status(401).send("Unauthorized: Invalid username or password");
    });
});

app.get("/getproducts", function(req, res) {
  db.all("SELECT * FROM products", function(err, rows) {
    if (err) {
      res.status(500).send("Error retrieving products from database");
      return;
    }
    res.send({ products: rows });
  });
});

app.listen(PORT, function() {
  console.log("Advanced express API listening on port 3000");
});
