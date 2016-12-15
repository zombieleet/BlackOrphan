#!/usr/bin/env node
'use strict';

const net = require('net');

const tcpServer = net.createServer((socket) => {

    console.log('connection has been established with ' + socket.remotePort + " " + socket.remoteAddress)
    process.stdin.setEncoding('utf8');
    process.stdin.on('readable', () => {
	let input = process.stdin.read();
	if ( input !== null ) {
	    socket.write(input);
	}
    });
    socket.on('data', (data) => {
	process.stdout.write(data)
    });
});

tcpServer.listen(21)
