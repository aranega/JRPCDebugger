Class {
	#name : #JRPCDebugger,
	#superclass : #Object,
	#instVars : [
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

{ #category : #actions }
JRPCDebugger >> context [
	^ self session context
]

{ #category : #actions }
JRPCDebugger >> currentMethodNode [
	^ self context method ast
]

{ #category : #actions }
JRPCDebugger >> currentMethodSource [
	^ self currentMethodNode source
]

{ #category : #actions }
JRPCDebugger >> currentNode [
	| pc |
	pc := self context pc.
	^ self currentMethodNode sourceNodeExecutedForPC: pc.
]

{ #category : #actions }
JRPCDebugger >> debug: processHash [
	process := self processWithHash: processHash.
	session := process
		newDebugSessionNamed: 'test session'
		startedAt: process suspendedContext.
	^ self lineInfo 
]

{ #category : #actions }
JRPCDebugger >> debugAST: aString [
]

{ #category : #actions }
JRPCDebugger >> display [
	| method start stop |
	method := self currentMethodNode.	
	start := self currentNode start.
	stop := self currentNode stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #actions }
JRPCDebugger >> evaluate: aString [
	^ JRPCDEvalInfo result: (Smalltalk compiler source: aString; context: self context; receiver: self context receiver; evaluate).
]

{ #category : #actions }
JRPCDebugger >> finish [
   |lastStatement currentNode|
	lastStatement := self currentMethodNode statements last.
	currentNode := self currentNode.
	[ (self context isNotNil or: [currentNode isKindOf: RBReturnNode]) or: [ currentNode = lastStatement ] ] whileFalse: [ self session stepOver. currentNode := self currentNode. ].
	^ self lineInfo 
]

{ #category : #actions }
JRPCDebugger >> init: aString [
	| context code |
	code := aString isEmpty
		ifTrue: [ [ | x |
			x := 5 + 1.
			'lalala' logCr ]]
		ifFalse: [ (Smalltalk compiler
				source: '[', aString, ']' ;
				evaluate) ].
	
	context := code asContext.
	process := Process
		forContext: context
		priority: Processor userInterruptPriority.
	session := process
		newDebugSessionNamed: 'test session'
		startedAt: context.
	^ self lineInfo
]

{ #category : #initialization }
JRPCDebugger >> initialize [
	super initialize.
	jrpcServer := JRPCServer http
						port: 4000;
						addHandlerNamed: 'initialize' block: [ :code | self init: code ];
						addHandlerNamed: 'display' block: [ self display ];
						addHandlerNamed: 'resume' block: [ self resume ];
						addHandlerNamed: 'evaluate' block: [ :expression | self evaluate: expression ];
						addHandlerNamed: 'nextStatement' block: [ self nextStatement ];
						addHandlerNamed: 'next' block: [ self next ];
						addHandlerNamed: 'step' block: [ self step ];
						addHandlerNamed: 'finish' block: [ self finish ];
						addHandlerNamed: 'list' block: [ self listProcesses ];
						addHandlerNamed: 'debug' block: [ :processHash | self debug: processHash ];
						yourself
]

{ #category : #actions }
JRPCDebugger >> lineInfo [
	| node |
	node := self currentNode.
	^ JRPCDLineInfo
		start: node start
		end: node stop
		source: self currentMethodSource
]

{ #category : #actions }
JRPCDebugger >> listProcesses [
	| processList |
	self flag: 'To be moved to the JRPC debuggers manager'.

	^ { 'processes' -> (self processes collect: [ :proc |
		{ 'string' -> proc printString. 'hash' -> proc hash } asDictionary ]) asArray } asDictionary
]

{ #category : #actions }
JRPCDebugger >> next [
	session stepOver.
	^ self lineInfo 
]

{ #category : #actions }
JRPCDebugger >> nextStatement [
	| node |
	node := self currentNode.
	[ node isKindOf: RBSequenceNode ]
		whileFalse: [ session stepOver.
			node := node parent ].
	^ self lineInfo
]

{ #category : #private }
JRPCDebugger >> processWithHash: anInteger [
	^ self processes detect: [ :p | p hash = anInteger ]
]

{ #category : #private }
JRPCDebugger >> processes [
	Smalltalk garbageCollectMost. "lose defunct processes"
	
	^ Process allSubInstances reject: [:each | each isTerminated]
]

{ #category : #actions }
JRPCDebugger >> resume [
	session resume.
	^ 'Execution terminated'
]

{ #category : #actions }
JRPCDebugger >> session [
	^ session
]

{ #category : #actions }
JRPCDebugger >> session: aDebugSession [
	session := aDebugSession
]

{ #category : #accessing }
JRPCDebugger >> start [
	jrpcServer start
]

{ #category : #actions }
JRPCDebugger >> step [
	session stepInto.
	^ self lineInfo 
]

{ #category : #accessing }
JRPCDebugger >> stop [
	jrpcServer stop
]
