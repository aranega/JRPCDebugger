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
JRPCDebugger >> disp [
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
						addHandlerNamed: 'display' block: [ self disp ];
						addHandlerNamed: 'nextStatement' block: [ self nextStatement ];
						yourself
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
