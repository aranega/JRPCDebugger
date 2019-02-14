Class {
	#name : #JRPCDebugger,
	#superclass : #Object,
	#instVars : [
		'debugContext',
		'debugSession',
		'process',
		'session',
		'jrpcServer'
	],
	#category : #JRPCDebugger
}

{ #category : #adding }
JRPCDebugger >> addEchoHandler [
	"For debugging purpose."
	jrpcServer
		addHandlerNamed: 'echo' block: [ :o | o asString ]
]

{ #category : #accessing }
JRPCDebugger >> debugContext [
	^ debugContext
]

{ #category : #accessing }
JRPCDebugger >> debugContext: anObject [
	debugContext := anObject
]

{ #category : #accessing }
JRPCDebugger >> debugSession [
	^ debugSession
]

{ #category : #accessing }
JRPCDebugger >> debugSession: anObject [
	debugSession := anObject
]

{ #category : #actions }
JRPCDebugger >> display [
	| method pc start stop |
	method := session context method.
	pc := session context pc.
	start := (method ast sourceNodeExecutedForPC: pc) start.
	stop := (method ast sourceNodeExecutedForPC: pc) stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #actions }
JRPCDebugger >> init [
	| method pc start stop |
	process := [ | x |
	x := 5 + 1.
	'lalala' logCr ] newProcess.
	session := process
		newDebugSessionNamed: 'test session'
		startedAt: process suspendedContext.
	method := session context method.
	pc := session context pc.
	start := (method ast sourceNodeExecutedForPC: pc) start.
	stop := (method ast sourceNodeExecutedForPC: pc) stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #initialization }
JRPCDebugger >> initialize [
	super initialize.
	jrpcServer := JRPCServer http
						port: 4000;
						addHandlerNamed: 'initialize' block: [ self init ];
						addHandlerNamed: 'display' block: [ self display ];
						addHandlerNamed: 'nextStatement' block: [ self nextStatement ];
						addHandlerNamed: 'next' block: [ self next ];
						addHandlerNamed: 'list' block: [ self listProcesses ];
						yourself
]

{ #category : #actions }
JRPCDebugger >> listProcesses [
	| processList |
	self flag: 'To be moved to the JRPC debuggers manager'.
	
	Smalltalk garbageCollectMost. "lose defunct processes"
	
	processList := Process allSubInstances
							reject: [:each | each isTerminated].
	processList := processList sort: [:a :b | a priority >= b priority].
	^ { 'processes' -> (processList collect: [ :proc |
		{ 'string' -> proc printString. 'hash' -> proc hash } asDictionary ]) asArray } asDictionary
]

{ #category : #actions }
JRPCDebugger >> next [
	| method pc start stop |
	session stepOver.
	method := session context method.
	pc := session context pc.
	start := (method ast sourceNodeExecutedForPC: pc) start.
	stop := (method ast sourceNodeExecutedForPC: pc) stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #actions }
JRPCDebugger >> nextStatement [
	| method pc node iteration start stop |
	method := session context method.
	pc := session context pc.
	node := method ast sourceNodeExecutedForPC: pc.
	iteration := 0.
	[ node isKindOf: RBSequenceNode ]
		whileFalse: [ iteration := iteration + 1.
			node := node parent ].
	1 to: iteration do: [ :i | session stepOver ].
	method := session context method.
	pc := session context pc.
	start := (method ast sourceNodeExecutedForPC: pc) start.
	stop := (method ast sourceNodeExecutedForPC: pc) stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #accessing }
JRPCDebugger >> start [
	jrpcServer start
]

{ #category : #accessing }
JRPCDebugger >> stop [
	jrpcServer stop
]
