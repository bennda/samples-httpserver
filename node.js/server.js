'use strict';

const express = require('express');
const PORT = 8080;
const HOST = '0.0.0.0';
const app = express();

function generateRandomNumber(req) {
    let min = 0;
    if (req.query.min) {
        min = Number(req.query.min)
    }
    let max = 1000;
    if (req.query.max) {
        max = Number(req.query.max)
    }
    return (Math.floor(Math.random()*(max-min))+min).toString()
}

app.listen(PORT, HOST, () => {
    console.log(`Running on http://${HOST}:${PORT}`);
});

app.get('/', (req, res) => {
    let mode = req.query.mode
    let text = "hello from node.js"

    switch (mode) {
        case "echo":
            text = req.query.text;
            break;
        case "random":
            text = generateRandomNumber(req);
            break;
    }

    res.send(text);
});

app.get('/echo', (req, res) => {
    let text = req.query.text;
    res.send("Text = " + text);
});

app.get('/random', (req, res) => {
    res.send(generateRandomNumber(req));
});