Class {
	#name : #JRPCASTDebugger,
	#superclass : #JRPCDebugger,
	#category : #JRPCDebugger
}

{ #category : #actions }
JRPCASTDebugger >> context [
	^ self session currentContext contextTag  
]

{ #category : #actions }
JRPCASTDebugger >> currentMethodNode [
	^ self currentNode methodNode
]

{ #category : #actions }
JRPCASTDebugger >> currentNode [
	^ self session currentNode
]

{ #category : #actions }
JRPCASTDebugger >> displayCurrentContext [
	^ self session currentContext asString
]

{ #category : #actions }
JRPCASTDebugger >> init: aString [
	process := DASTInterpreter new.
	process initializeWithProgram: (RBParser parseExpression: aString).
	session := process.
	^ self lineInfo
]

{ #category : #actions }
JRPCASTDebugger >> initialize [
	super initialize.
	jrpcServer addHandlerNamed: 'currentcontext' block: [ self displayCurrentContext ].
						
]

{ #category : #actions }
JRPCASTDebugger >> resume [
	^ JRPCDEvalInfo result: process evaluate.
]
